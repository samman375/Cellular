#include <stdio.h>
#include <stdint.h>

#define MIN_WORLD_SIZE     1
#define MAX_WORLD_SIZE   128
#define MIN_GENERATIONS -256
#define MAX_GENERATIONS  256
#define MIN_RULE           0
#define MAX_RULE         255

#define ALIVE_CHAR        '#'
#define DEAD_CHAR         '.'

static int8_t cells[MAX_GENERATIONS + 1][MAX_WORLD_SIZE];

static void run_generation(int world_size, int which_generation, int rule);
static void print_generation(int world_size, int which_generation);

int main(int argc, char *argv[]) {
    printf("Enter world size: ");
    int world_size = 0;
    scanf("%d", &world_size);
    if (world_size < MIN_WORLD_SIZE) {goto invalid_world_size;};
    if (world_size > MAX_WORLD_SIZE) {goto invalid_world_size;};
    goto scan_rule;
invalid_world_size:
    printf("Invalid world size\n");
    return 1;
scan_rule:
    printf("Enter rule: ");
    int rule = 0;
    scanf("%d", &rule);
    if (rule < MIN_RULE) {goto invalid_rule;};
    if (rule > MAX_RULE) {goto invalid_rule;};
    goto scan_generations;
invalid_rule:
    printf("Invalid rule\n");
    return 1;
scan_generations:
    printf("Enter how many generations: ");
    int n_generations = 0;
    scanf("%d", &n_generations);
    if (n_generations < MIN_GENERATIONS) {goto invalid_n_generations;};
    if (n_generations > MAX_GENERATIONS) {goto invalid_n_generations;};
    goto valid_inputs;
invalid_n_generations:
    printf("Invalid number of generations\n");
    return 1;
valid_inputs:
    putchar('\n');
    int reverse = 0;
    int arg0;
    int arg1;
    int arg2;
    if (n_generations >= 0) {goto positive_n_generations;};
    reverse = 1;
    n_generations = n_generations * -1;
positive_n_generations:
    //int col = world_size / 2;
    cells[0][world_size / 2] = 1;
    int g = 1;
main_loop0:
    arg0 = world_size;
    arg1 = g;
    arg2 = rule;
    run_generation(arg0, arg1, arg2);
    g++;
    if (g <= n_generations) {goto main_loop0;};
    if (reverse != 1) {goto not_reversed;};
    g = n_generations;
main_loop1:
    arg0 = world_size;
    arg1 = g;
    print_generation(world_size, g);
    g--;
    if (g >= 0) {goto main_loop1;};
    goto generations_printed;
not_reversed:
    g = 0;
main_loop2:
    arg0 = world_size;
    arg1 = g;
    print_generation(arg0, arg1);
    g++;
    if (g <= n_generations) {goto main_loop2;};
generations_printed:
    return 0;
}

static void run_generation(int world_size, int which_generation, int rule) {
    int x = 0;
run_loop0: ;
    int left = 0;
    if (x <= 0) {goto left_bounds;};
    which_generation--;
    x--;
    left = cells[which_generation][x];
    x++;
    which_generation++;
left_bounds:
    which_generation--;
    int centre = cells[which_generation][x];
    int right = 0;
    which_generation++;
    if (x >= world_size) {goto right_bounds;};
    x++;
    which_generation--;
    right = cells[which_generation][x];
    x--;
    which_generation++;
right_bounds: ;
    int state = left << 2;
    centre <<= 1;
    right <<= 0;
    state |= centre;
    state |= right;
    int bit = 1 << state;
    int set = rule & bit;
    if (set == 0) {goto dead_bit;};
    cells[which_generation][x] = 1;
    goto bit_set;
dead_bit:
    cells[which_generation][x] = 0;
bit_set:
    x++;
    if (x < world_size) {goto run_loop0;};
}

static void print_generation(int world_size, int which_generation) {
    printf("%d", which_generation);
    putchar('\t');
    int x = 0;
print_loop0:
    if (cells[which_generation][x] != 1) {goto print_dead;};
    putchar(ALIVE_CHAR);
    goto char_printed;
print_dead:
    putchar(DEAD_CHAR);
char_printed:
    x++;
    if (x < world_size) {goto print_loop0;};
    putchar('\n');
}



