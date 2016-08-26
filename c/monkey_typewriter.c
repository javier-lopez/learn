#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

char * phrase   = "methinks it is like a weasel";
char * alphabet = "abcdefghijklmnopqrstuvwxyz ";
int phrase_len  = 28;

int randint(int n) {
  if ((n - 1) == RAND_MAX) {
    return rand();
  } else {
    // Chop off all of the values that would cause skew...
    long end = RAND_MAX / n; // truncate skew
    assert (end > 0L);
    end *= n;

    // ... and ignore results from rand() that fall above that limit.
    // (Worst case the loop condition should succeed 50% of the time,
    // so we can expect to bail out of this loop pretty quickly.)
    int r;
    while ((r = rand()) >= end);

    return r % n;
  }
}

void monkey(char * monkey_phrase) {
    int i; for (i = 0; i < phrase_len; i++) {
        monkey_phrase[i] = alphabet[randint(27)];
    }
}

int evaluate(char * monkey_phrase, char * phrase) {
    int score = 0; int i = 0;
    for (i = 0; i < phrase_len; i++) {
        if (monkey_phrase[i] == phrase[i]) {
            score++;
        }
    }
    if (score > 0) score = (score * 100) / phrase_len;
    return score;
}

int main(int argc, char const* argv[]) {
    char best_phrase[phrase_len];
    int  best_score = 0; int score = 0; int i = 0;
    char monkey_phrase[phrase_len];

    while (1) {
        monkey(monkey_phrase);
        score = evaluate(monkey_phrase, phrase);
        if (score == 100) {
            printf("monkey wrote it and only took %d tries!\n", i);
            exit(0);
        } else {
            if (best_score < score) {
                best_score  = score;
                strncpy(best_phrase, monkey_phrase, sizeof(monkey_phrase));
            }
            if (i % 100000 == 0)
                printf("%10d - best score so far against '%s' is '%s' (%d%%), current '%s' (%d%%)\n", i, phrase, best_phrase, best_score, monkey_phrase, score);
        }
        i++;
    }

    fflush(stdout);
    if (ferror(stdout)) exit(EXIT_FAILURE);
    return EXIT_SUCCESS;
}
