#include "ripes_system.h"
#include <stdio.h>

// RIPES I/O
#define SW0 (0x01)

// RIPES Game I/O Addresses

volatile unsigned int *led_base = LED_MATRIX_0_BASE;
volatile unsigned int *switch_base = SWITCHES_0_BASE;
volatile unsigned int *food = LED_MATRIX_0_BASE;
volatile unsigned int *d_pad_up = D_PAD_0_UP;
volatile unsigned int *d_pad_do = D_PAD_0_DOWN;
volatile unsigned int *d_pad_le = D_PAD_0_LEFT;
volatile unsigned int *d_pad_ri = D_PAD_0_RIGHT;

// COLORS
#define SNAKE_COLOR 0x00FF00
#define BACKGROUND_COLOR 0xFFFFFF
#define FOOD_COLOR 0xFF0000
#define BORDER_COLOR 0x000000

// GAME SETTINGS
#define MAX_SNAKE_LENGTH 50
#define PIXEL_SIZE 2
#define BOARD_SIZE (LED_MATRIX_0_WIDTH * LED_MATRIX_0_HEIGHT)
#define WAIT_NUM 3000

// SNAKE POSITION
#define SNAKE_START_X 10
#define SNAKE_START_Y 10

typedef enum {
    GAME_OVER,
    PLAYING
} GameState;

typedef enum {
    UP,
    DOWN,
    LEFT,
    RIGHT
} Direction;

typedef struct {
    unsigned y;
    unsigned x;
} Food;

typedef struct {
    unsigned int x;
    unsigned int y;
    Direction direction;
} SnakeSegment;

typedef struct {
    SnakeSegment segments[MAX_SNAKE_LENGTH];
    int length;
    Food food;
} Snake;

void initSnake(Snake *snake) {
    snake->length = 1;
    snake->segments[0].x = SNAKE_START_X;
    snake->segments[0].y = SNAKE_START_Y;
    snake->segments[0].direction = RIGHT;
    snake->food.x = 0;
    snake->food.y = 0;
}

void clearBoard() {
    // Draw the background
    for (int y = PIXEL_SIZE; y < LED_MATRIX_0_HEIGHT - PIXEL_SIZE; y++) {
        for (int x = PIXEL_SIZE; x < LED_MATRIX_0_WIDTH - PIXEL_SIZE; x++) {
            *(led_base + y * LED_MATRIX_0_WIDTH + x) = BACKGROUND_COLOR;
        }
    }

    // Draw the border
    for (int i = 0; i < LED_MATRIX_0_WIDTH; i++) {
        for (int j = 0; j < PIXEL_SIZE; j++) {
            *(led_base + j * LED_MATRIX_0_WIDTH + i) = BORDER_COLOR; // Top border
            *(led_base + (LED_MATRIX_0_HEIGHT - 1 - j) * LED_MATRIX_0_WIDTH + i) = BORDER_COLOR; // Bottom border
        }
    }
    
    for (int i = 0; i < LED_MATRIX_0_HEIGHT; i++) {
        for (int j = 0; j < PIXEL_SIZE; j++) {
            *(led_base + i * LED_MATRIX_0_WIDTH + j) = BORDER_COLOR; // Left border
            *(led_base + i * LED_MATRIX_0_WIDTH + (LED_MATRIX_0_WIDTH - 1 - j)) = BORDER_COLOR; // Right border
        }
    }

}

void wait() {
    for (int i = 0; i < WAIT_NUM; i++);
}

void drawSnakeAndFood(Snake *snake) {
    // Draw the snake
    for (int i = 0; i < snake->length; i++) {
        for (int x = 0; x < PIXEL_SIZE; x++) {
            for (int y = 0; y < PIXEL_SIZE; y++) {
                if (i == 0) {
                    *(led_base + (snake->food.y + y) * LED_MATRIX_0_WIDTH + (snake->food.x + x)) = FOOD_COLOR;
                }
                *(led_base + (snake->segments[i].y + y) * LED_MATRIX_0_WIDTH + (snake->segments[i].x + x)) = SNAKE_COLOR;
            }
        }
    }
}

int main(){
    Snake snake;
    initSnake(&snake);

    clearBoard();

    GameState gameState = PLAYING;

    int counter = 0;
    

    while(1){
        while (gameState == PLAYING) {
            // Clear the board
            clearBoard();

            // Draw the food
            if (snake.food.x == 0 && snake.food.y == 0) {
                int x = (rand()+counter) % LED_MATRIX_0_WIDTH-PIXEL_SIZE;
                int y = (rand()+counter) % LED_MATRIX_0_HEIGHT-PIXEL_SIZE;
                
                if (x % 2 != 0) x--;
                if (y % 2 != 0) y--;

                if (x < PIXEL_SIZE) x = PIXEL_SIZE;
                if (y < PIXEL_SIZE) y = PIXEL_SIZE;

                snake.food.x = x;
                snake.food.y = y;
            }

            // Draw the snake and the food
            drawSnakeAndFood(&snake);

            // Move the snake
            for (int i = snake.length - 1; i > 0; i--) {
                snake.segments[i].x = snake.segments[i - 1].x;
                snake.segments[i].y = snake.segments[i - 1].y;
            }

            if (*d_pad_up == 1 && snake.segments[0].direction != DOWN) snake.segments[0].direction = UP;
            else if (*d_pad_do == 1 && snake.segments[0].direction != UP) snake.segments[0].direction = DOWN;
            else if (*d_pad_le == 1 && snake.segments[0].direction != RIGHT) snake.segments[0].direction = LEFT;
            else if (*d_pad_ri == 1 && snake.segments[0].direction != LEFT) snake.segments[0].direction = RIGHT;

            switch (snake.segments[0].direction) {
                case UP:
                    snake.segments[0].y-=PIXEL_SIZE;
                    break;
                case DOWN:
                    snake.segments[0].y+=PIXEL_SIZE;
                    break;
                case LEFT:
                    snake.segments[0].x-=PIXEL_SIZE;
                    break;
                case RIGHT:
                    snake.segments[0].x+=PIXEL_SIZE;
                    break;
            }

            // Check if the snake has collided with the wall
            if (snake.segments[0].x < PIXEL_SIZE || snake.segments[0].x >= LED_MATRIX_0_WIDTH-PIXEL_SIZE || snake.segments[0].y < PIXEL_SIZE || snake.segments[0].y >= LED_MATRIX_0_HEIGHT-PIXEL_SIZE) {
                gameState = GAME_OVER;
            }

            // Check if the snake has collided with itself
            for (int i = 1; i < snake.length; i++) {
                if (snake.segments[0].x == snake.segments[i].x && snake.segments[0].y == snake.segments[i].y) {
                    gameState = GAME_OVER;
                    break;
                }
            }

            // Check if the snake has eaten the food
            if (snake.segments[0].x == snake.food.x && snake.segments[0].y == snake.food.y) {
                snake.length++;
                snake.food.x = 0;
                snake.food.y = 0;
            }

            // Wait
            wait();
            counter++;
        }
        
        int restart_flag = *(switch_base) & SW0 && gameState == GAME_OVER;
        // printf("Restart flag: %d\n", restart_flag);
        // printf("Game state: %d\n", gameState);
        if (restart_flag) {
            // Restart the game
            initSnake(&snake);
            gameState = PLAYING;
            printf("Restarted game\n");
        }
        printf("Game state: %d\n", gameState);
    }
    
    return 0;
}