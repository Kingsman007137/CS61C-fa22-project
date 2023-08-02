#include "state.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_state_t* state, unsigned int snum);
static char next_square(game_state_t* state, unsigned int snum);
static void update_tail(game_state_t* state, unsigned int snum);
static void update_head(game_state_t* state, unsigned int snum);

/* Task 1 */
game_state_t* create_default_state() {
  // TODO: Implement this function.
  game_state_t* state = (game_state_t*)malloc(sizeof(game_state_t));
  state->num_rows = 18;
  state->num_snakes = 1;
  state->board = (char **)malloc(state->num_rows * sizeof(char*));
  state->snakes = (snake_t *)malloc(state->num_snakes * sizeof(snake_t));
  state->snakes->head_row = 2;
  state->snakes->head_col = 4;
  state->snakes->tail_row = 2;
  state->snakes->tail_col = 2;
  state->snakes->live = true;

  // Allocate memory for each row in state->board
  for (int i = 0; i < state->num_rows; i++) {
    state->board[i] = (char*)malloc(21 * sizeof(char));
  }

  // Initialize the board with '#' and ' '
  for (int i = 0; i < state->num_rows; i++) {
    state->board[i][0] = '#';
    state->board[i][19] = '#';
    state->board[i][20] = '\0';
    for (int j = 1; j < 19; j++) {
      if (i == 0 || i == state->num_rows - 1) {
        state->board[i][j] = '#';
      } else {
        state->board[i][j] = ' ';
      }
    }
  }

  state->board[state->snakes->head_row][state->snakes->head_col] = 'D';
  state->board[state->snakes->tail_row][state->snakes->tail_col] = 'd';
  state->board[2][3] = '>';  // Maybe need to change
  state->board[2][9] = '*';

  return state;
}

/* Task 2 */
void free_state(game_state_t* state) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_rows; i ++) {
    free(state->board[i]);
  }

  free(state->board);
  free(state->snakes);
  free(state);

  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  // TODO: Implement this function.
  for (int i = 0; i < state->num_rows; i++) {
    //IDK why it is 21 width every string but the file size is 396...
    fprintf(fp, "%s\n", state->board[i]);
  }

  return;
}

/*
  Saves the current state into filename. Does not modify the state object.
  (already implemented for you).
*/
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_state_t* state, unsigned int row, unsigned int col) {
  return state->board[row][col];
}

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_state_t* state, unsigned int row, unsigned int col, char ch) {
  state->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  return c == 'w' || c == 'a' || c == 's' || c == 'd';
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  return c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x';
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  return is_head(c) || is_tail(c) || c == '^' || c == '<' || c == 'v' || c == '>';
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  char ret = '?';
  switch (c) {
  case '^':
    ret = 'w';
    break;
  case '<':
    ret = 'a';
    break;
  case 'v':
    ret = 's';
    break;
  case '>':
    ret = 'd';
    break;
  default:
    break;
  }
  return ret;
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  char ret = '?';
  switch (c) {
  case 'W':
    ret = '^';
    break;
  case 'A':
    ret = '<';
    break;
  case 'S':
    ret = 'v';
    break;
  case 'D':
    ret = '>';
    break;
  default:
    break;
  }
  return ret;
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's' || c == 'S') {
    return cur_row + 1;
  } else if (c == '^' || c == 'w' || c == 'W') {
    return cur_row - 1;
  }
  return cur_row;
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
    if (c == '>' || c == 'd' || c == 'D') {
    return cur_col + 1;
  } else if (c == '<' || c == 'a' || c == 'A') {
    return cur_col - 1;
  }
  return cur_col;
}

/*
  Task 4.2

  Helper function for update_state. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  if (snum >= state->num_snakes) {
    return '?';
  }

  unsigned int row = state->snakes[snum].head_row;
  unsigned int col = state->snakes[snum].head_col;
  char head = get_board_at(state, row, col);

  return get_board_at(state, get_next_row(row, head), get_next_col(col, head));
}

/*
  Task 4.3

  Helper function for update_state. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t temp = state->snakes[snum];
  char head = get_board_at(state, temp.head_row, temp.head_col);
  set_board_at(state, get_next_row(temp.head_row, head), get_next_col(temp.head_col, head), head);
  set_board_at(state, temp.head_row, temp.head_col, head_to_body(head));

  state->snakes[snum].head_row = get_next_row(temp.head_row, head);
  state->snakes[snum].head_col = get_next_col(temp.head_col, head);

  return;
}

/*
  Task 4.4

  Helper function for update_state. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  snake_t temp = state->snakes[snum];
  char tail = get_board_at(state, temp.tail_row, temp.tail_col);
  char tail_next = get_board_at(state, get_next_row(temp.tail_row, tail), get_next_col(temp.tail_col, tail));
  //update the tail-next to tail first
  set_board_at(state, get_next_row(temp.tail_row, tail), get_next_col(temp.tail_col, tail), body_to_tail(tail_next));
  set_board_at(state, temp.tail_row, temp.tail_col, ' ');

  state->snakes[snum].tail_row = get_next_row(temp.tail_row, tail);
  state->snakes[snum].tail_col = get_next_col(temp.tail_col, tail);

  return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  // TODO: Implement this function.
  for (unsigned i = 0; i < state->num_snakes; i++) {
    snake_t temp = state->snakes[i];
    char head = get_board_at(state, temp.head_row, temp.head_col);
    char head_next = get_board_at(state, get_next_row(temp.head_row, head), get_next_col(temp.head_col, head));

    if (is_snake(head_next) || head_next == '#') {
      set_board_at(state, temp.head_row, temp.head_col, 'x');
      state->snakes[i].live = false;
    } else if (head_next == '*') {
      update_head(state, i);
      add_food(state);
    } else {
      update_head(state, i);
      update_tail(state, i);
    }
  }

  return;
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  // TODO: Implement this function.
  FILE *fp = fopen(filename, "r");
  if (fp == NULL) {
    return NULL;
  }

  game_state_t *state = (game_state_t *)malloc(sizeof(game_state_t));
  unsigned rows = 0;
  char temp[100][100];
  //every string's length
  int length[100];
  while(fgets(temp[rows], 99, fp) != NULL) {
    temp[rows][strlen(temp[rows]) - 1] = '\0';
    length[rows] = (int)strlen(temp[rows]);
    rows ++;
  }
  state->num_rows = rows;
  state->board = (char **)malloc(state->num_rows * sizeof(char *));

  for (int i = 0; i < state->num_rows; i++) {
    state->board[i] = (char *)malloc((unsigned int)(length[i] + 1) * sizeof(char));
    strcpy(state->board[i], temp[i]);
    state->board[i][length[i]] = '\0';
  }

  fclose(fp);
  return state;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_state_t* state, unsigned int snum) {
  // TODO: Implement this function.
  if (snum >= state->num_snakes) {
    return;
  }

  unsigned row = state->snakes[snum].tail_row;
  unsigned col = state->snakes[snum].tail_col;

  while (!is_head(get_board_at(state, row, col))) {
    row = get_next_row(row, get_board_at(state, row, col));
    col = get_next_col(col, get_board_at(state, row, col));
  }

  state->snakes[snum].head_row = row;
  state->snakes[snum].head_col = col;

  return;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
  // TODO: Implement this function.
  unsigned int tails = 0;
  unsigned int col[100];
  unsigned int row[100];
  for (unsigned int i = 0; i < state->num_rows; i ++) {
    for (unsigned int j = 0; j < strlen(state->board[i]); j ++) {
      if (is_tail(get_board_at(state, i, j))) {
        row[tails] = i;
        col[tails] = j;
        tails ++;
      }
    }
  }

  state->num_snakes = tails;
  state->snakes = (snake_t *)malloc(state->num_snakes * sizeof(snake_t));
  for (unsigned int i = 0; i < state->num_snakes; i ++) {
    state->snakes[i].tail_row = row[i];
    state->snakes[i].tail_col = col[i];
    state->snakes[i].live = true;
    find_head(state, i);
  }

  return state;
}
