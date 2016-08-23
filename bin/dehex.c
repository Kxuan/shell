#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <unistd.h>
#include <ctype.h>

uint8_t hex_dict[0x100] = {
    [0 ... 0xff] = 0xff,
    ['0'] = 0,
    ['1'] = 1,
    ['2'] = 2,
    ['3'] = 3,
    ['4'] = 4,
    ['5'] = 5,
    ['6'] = 6,
    ['7'] = 7,
    ['8'] = 8,
    ['9'] = 9,
    ['a'] = 10,
    ['b'] = 11,
    ['c'] = 12,
    ['d'] = 13,
    ['e'] = 14,
    ['f'] = 15,
    ['A'] = 10,
    ['B'] = 11,
    ['C'] = 12,
    ['D'] = 13,
    ['E'] = 14,
    ['F'] = 15
};
int main() {
    static uint8_t read_buf[4096];
    static uint8_t write_buf[4096];
    ssize_t nbytes;
    uint8_t *p_read, *p_write, *read_buf_end;
    uint8_t hi_part, num, is_high_set = 0;
    while ((nbytes =  read(STDIN_FILENO, read_buf, sizeof(read_buf))) > 0) {
        read_buf_end = read_buf + nbytes;
        p_write = write_buf;
        p_read = read_buf;
        for (; p_read < read_buf_end; p_read++) {
            num = hex_dict[*p_read];
            if (num == 0xff) continue;
            if (is_high_set) {
                *p_write = (hi_part << 4) | num;
                p_write++;
                is_high_set = 0;
            } else {
                hi_part = num;
                is_high_set = 1;
            }
        }
        
        write(STDOUT_FILENO, write_buf, p_write - write_buf);
    }

    if (is_high_set) {
        fprintf(stderr, "Unexpected end of input\n");
        return 1;
    }
    return 0;
}
