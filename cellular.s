########################################################################
# COMP1521 20T2 --- assignment 1: a cellular automaton renderer
#
# Written by Samuel Thorley (z5257239), July 2020.


# Maximum and minimum values for the 3 parameters.

MIN_WORLD_SIZE	=    1
MAX_WORLD_SIZE	=  128
MIN_GENERATIONS	= -256
MAX_GENERATIONS	=  256
MIN_RULE		=    0
MAX_RULE		=  255

# Characters used to print alive/dead cells.

ALIVE_CHAR		= '#'
DEAD_CHAR		= '.'

# Maximum number of bytes needs to store all generations of cells.

MAX_CELLS_BYTES	= (MAX_GENERATIONS + 1) * MAX_WORLD_SIZE

	.data

# `cells' is used to store successive generations.  Each byte will be 1
# if the cell is alive in that generation, and 0 otherwise.

cells:					.space MAX_CELLS_BYTES


# Some strings you'll need to use:

prompt_world_size:		.asciiz "Enter world size: "
error_world_size:		.asciiz "Invalid world size\n"
prompt_rule:			.asciiz "Enter rule: "
error_rule:				.asciiz "Invalid rule\n"
prompt_n_generations:	.asciiz "Enter how many generations: "
error_n_generations:	.asciiz "Invalid number of generations\n"

	.text


	# world_size stored in $t0
	# rule stored in $t1
	# n_generations stored in $t2
	# reverse stored in $t3
	# column index stored in $s0
	# row index stored in $s1
	# g stored in $t4
	# ra value stored in $t5


main:
	
	la		$a0, prompt_world_size 						# printf("Enter world size: ");
    li		$v0, 4
	syscall
	
	li		$t0, 0										# int world_size = 0;
	li		$v0, 5										# scanf("%d", &world_size);
    syscall
	move	$t0, $v0
	
	blt		$t0, MIN_WORLD_SIZE, invalid_world_size 	# if (world_size < MIN_WORLD_SIZE) goto invalid_world_size;
	bgt		$t0, MAX_WORLD_SIZE, invalid_world_size		# if (world_size > MAX_WORLD_SIZE) goto invalid_world_size;
	
	b		scan_rule									# goto scan_rule;
invalid_world_size:

	la		$a0, error_world_size						# printf("Invalid world size\n");
	li		$v0, 4
	syscall
	
	b 		generations_printed
scan_rule:

	la		$a0, prompt_rule							# printf("Enter rule: ");
    li		$v0, 4
	syscall

	li		$t1, 0 										# int rule = 0;
    li		$v0, 5 										# scanf("%d", &rule);
	syscall
    move	$t1, $v0

	blt		$t1, MIN_RULE, invalid_rule			 		# if (rule < MIN_RULE) goto invalid_rule;
	bgt		$t1, MAX_RULE, invalid_rule					# if (rule > MAX_RULE) goto invalid_rule;
	
	b		scan_generations 							# goto scan_generations;
invalid_rule:

	la		$a0, error_rule 							# printf("Invalid rule\n");
	li		$v0, 4
	syscall

	b 		generations_printed
scan_generations:

	la		$a0, prompt_n_generations    				# printf("Enter how many generations: ");
	li		$v0, 4
	syscall
	
    li		$t2, 0 										# int n_generations = 0;
    li		$v0, 5 										# scanf("%d", &n_generations);
	syscall
    move	$t2, $v0
	mul		$t2, $t2, -1
	
	blt		$t2, MIN_GENERATIONS, invalid_n_generations # if (n_generations < MIN_GENERATIONS) goto invalid_n_generations;
    bgt		$t2, MAX_GENERATIONS, invalid_n_generations	# if (n_generations > MAX_GENERATIONS) goto invalid_n_generations;

	b 		valid_inputs 								# goto valid_inputs;
invalid_n_generations:

	la		$a0, error_n_generations 					# printf("Invalid number of generations\n");
    li		$v0, 4
	syscall
	
	b 		generations_printed
valid_inputs:

	li		$a0, '\n'									# putchar('\n');
	li		$v0, 11
	syscall

    li		$t3, 0										# int reverse = 0;
    bge		$t2, 0, positive_n_generations 				# if (n_generations >= 0) goto positive_n_generations;
    li		$t3, 1 										# reverse = 1;
    mul		$t2, $t2, -1 								# n_generations = n_generations * -1;
positive_n_generations:

	div		$s0, $t0, 2									# col = world_size / 2;
	li		$s1, 0
	mul		$s2, $s1, $t0								# $s2 = row * world_size
	add		$s2, $s2, $s0								# $s2 = $s2 + col
	addi	$s2, $s2, -1								# $s2 = $s2 - 1
	mul		$s2, $s2, 4
	la		$s5, cells									# $s5 = &cells[0][0];
	add		$s2, $s5, $s2								# $s2 = &cells[0][0] + index
	li		$s3, 1
	sw		$s3, ($s2) 									# $s2 = 1;

	li		$t4, 1 										# int g = 1;
main_loop0:

    move	$a0, $t0 									# arg0 = world_size
	move	$a1, $t4 									# arg1 = g;
	move	$a2, $t1 									# arg2 = rule;
	move	$t5, $ra
	jal		run_generation								# run_generation(world_size, g, rule);
	move	$ra, $t5
	addi	$t4, $t4, 1 								# g++;
	ble		$t4, $t2, main_loop0 						# if (g <= n_generations) goto main_loop0;
    
	bne		$t3, $s3, not_reversed 						# if (reverse != 1) goto not_reversed;
    move	$t4, $t2 									# int g = n_generations;
main_loop1:

	move	$a0, $t0									# arg0 = world_size;
	move	$a1, $t4									# arg1 = g;
	move	$t5, $ra
	jal 	print_generation							# print_generation(world_size, g);
	move	$ra, $t5
	addi	$t4, $t4, -1 								# g--;
	bgez	$t4, main_loop1 							# if (g >= 0) goto main_loop1;
	b 		generations_printed 						# goto generations_printed;
not_reversed:

	li		$t4, 0										# int g = 0;
	
main_loop2:
    
	move	$a0, $t0									# arg0 = world_size;
	move	$a1, $t4									# arg1 = g;
	move	$t5, $ra
	jal		print_generation							# print_generation(world_size, g);
	move	$ra, $t5
	addi	$t4, $t4, 1 								# g++;
    ble		$t4, $t2, main_loop2 						# if (g <= n_generations) goto main_loop2;
generations_printed:

	jr		$ra












	#
	# Given `world_size', `which_generation', and `rule', calculate
	# a new generation according to `rule' and store it in `cells'.
	#

	# world_size given in $a0
	# which_generation given in $a1
	# rule given in $a2
	# loop integer x stored in $s0
	# left stored in $s1
	# center stored in $s2
	# right stored in $s3
	# &cells[0][0], then temp variable in $s4
	# address of target from &cell[0][0] in $s5
	# state in $s6
	# bit and set in $s7


	# Registers with changed values:
	# $s0, $s1, $s2, $s3, $s4, $s5, $s6, $s7

run_generation:

	li		$s0, 0 										# int x = 0;
run_loop0:
	
	li		$s1, 0 										# int left = 0;
    blez	$s0, left_bounds 							# if (x <= 0) goto left_bounds:
    addi	$a1, $a1, -1 								# which_generation--;
	addi	$s0, $s0, -1								# x--;
	la		$s4, cells									# left = cells[which_generation][x];
	mul		$s5, $a1, $a0
	add		$s5, $s5, $s0
	addi	$s5, $s5, -1
	mul		$s5, $s5, 4
	add		$s5, $s5, $s4
	lw		$s1, ($s5)
	addi	$s0, $s0, 1									# x++;
	addi	$a1, $a1, 1 								# which_generation++;
left_bounds:

	addi	$a1, $a1, -1 								# which_generation--;
    la		$s4, cells									# int centre = cells[which_generation][x];
    mul		$s5, $a1, $a0
	add		$s5, $s5, $s0
	addi	$s5, $s5, -1
	mul		$s5, $s5, 4
	add		$s5, $s5, $s4
	lw		$s2, ($s5)
	li		$s3, 0										# int right = 0;
	addi	$a1, $a1, 1									# which_generation++;
	addi	$s4, $a0, -1
    bge		$s0, $s4, right_bounds 						# if (x >= world_size) goto right_bounds;
	addi	$s0, $s0, 1									# x++;
	addi	$a1, $a1, -1								# which_generation--;
	mul		$s5, $a1, $a0								# right = cells[which_generation][x];
	add		$s5, $s5, $s0
	addi	$s5, $s5, -1
	mul		$s5, $s5, 4
	la		$s4, cells
	add		$s5, $s5, $s4
	lw		$s3, ($s5)
	addi	$s0, $s0, -1								# x--;
	addi 	$a1, $a1, 1									# which_generation++;
right_bounds:

    sll		$s6, $s1, 2									# int state = left << 2; 
	sll		$s2, $s2, 1									# centre <<= 1;
	sll		$s3, $s3, 0									# right <<= 0;
	or		$s6, $s6, $s2								# state |= centre;
	or		$s6, $s6, $s3								# state |= right;
	li		$s4, 1										
	sllv	$s7, $s4, $s6								# int bit = 1 << state;
    and		$s7, $a2, $s7								# int set = rule & bit;

    la		$s4, cells 									# &cells[which_generation][x];
	mul		$s5, $a0, $a1
	add		$s5, $s5, $s0
	addi	$s5, $s5, -1
	mul		$s5, $s5, 4
	add		$s5, $s5, $s4
	li		$s4, 1
	beqz	$s7, dead_bit							# if (set != 1) goto dead_bit;
	sw		$s4, ($s5)									# cells[which_generation][x] = 1;
	b 		bit_set										# goto bit_set;
dead_bit:

    li		$s4, 0										# cells[which_generation][x] = 0;
	sw		$s4, ($s5)
bit_set:

	addi	$s0, $s0, 1									# x++;
    blt		$s0, $a0, run_loop0							# if (x < world_size) goto run_loop0;

	jr	$ra


	#
	# Given `world_size', and `which_generation', print out the
	# specified generation.
	#

	# $a0 contains supplied world_size, moved to $s0
	# $a1 contains which_generation, moved to $s1
	# x stored in $s2
	# address of cells[which_generation][x] in $s3
	# comparison value 1 in $s4
	# temporary address storage in $s5
	# temporary value storage in $s6

	# Registers with changed values:
	# $a0, $s0, $s1, $s2, $s3, $s4, $s5, $s6, $v0

print_generation:

	move	$s0, $a0									# world_size = $a0
	move	$s1, $a1									# which_generation = $a1
	move	$a0, $s1 									# printf("%d", which_generation);
    li		$v0, 1
	syscall

	li		$a0, '\t'									# putchar('\t');
	li		$v0, 11
	syscall

    li 		$s2, 0 										# int x = 0;
print_loop0:

    mul		$s3, $s1, $s0								# address = which_generation * world_size;
	add		$s3, $s3, $s2								# address += x;
	addi	$s3, $s3, -1								# address--;
	mul		$s3, $s3, 4
	la		$s5, cells
	add		$s3, $s3, $s5
	li		$s4, 1										# temp = 1;
	lw		$s6, ($s3)

	bne		$s6, $s4, print_dead 						# if (cells[which_generation][x] != temp) goto print_dead;
	li		$a0, ALIVE_CHAR 							# putchar(ALIVE_CHAR);
	li		$v0, 11
	syscall

	b char_printed										# goto char_printed;

print_dead:
    li		$a0, DEAD_CHAR 								# putchar(DEAD_CHAR);
	li		$v0, 11
	syscall

char_printed:
	addi	$s2, $s2, 1 								# x++;
	blt		$s2, $s0, print_loop0 						# if (x < world_size) goto print_loop0;

    li		$a0, '\n' 									# putchar('\n');
	li		$v0, 11
	syscall

	jr	$ra
