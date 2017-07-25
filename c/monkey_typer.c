#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <time.h>

char alphabet[] = "abcdefghijklmnopqrstuvwxyz ";

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

char * monkey(long unsigned int len) {
    char * monkey_phrase = malloc(sizeof(char) * len);
    int i; for (i = 0; i < len; i++) {
        monkey_phrase[i] = alphabet[randint(27)];
    }
    monkey_phrase[len] = '\0';
    return monkey_phrase;
}

int evaluate(char * monkey_phrase, char * phrase) {
    int score = 0; int i = 0;
    for (i = 0; i < strlen(phrase); i++) {
        if (monkey_phrase[i] == phrase[i]) {
            score++;
        }
    }
    if (score > 0) score = (score * 100) / strlen(phrase);
    return score;
}

int main(int argc, char const* argv[]) {
    if(argc == 1){
        printf("Usage: %s phrase\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char phrase[strlen(argv[1]) + 1]; strncpy(phrase, argv[1], sizeof(phrase));
    char best_phrase[sizeof(phrase)];
    char monkey_phrase[sizeof(phrase)];
    int  best_score = 0; int score = 0; long unsigned int i = 0;

    srand(time(NULL)); while (1) {
        strncpy(monkey_phrase, monkey(sizeof(phrase)-1), sizeof(phrase));
        score = evaluate(monkey_phrase, phrase);
        if (score == 100) {
            printf("monkey wrote it and only took %lu tries!\n", i);
            exit(EXIT_SUCCESS);
        } else {
            if (best_score < score) {
                best_score  = score;
                strncpy(best_phrase, monkey_phrase, sizeof(monkey_phrase));
            }
            if (i % 100000 == 0)
                printf("%10lu - best score so far against '%s' is '%s' (%d%%), current '%s' (%d%%)\n", i, phrase, best_phrase, best_score, monkey_phrase, score);
        }
        i++;
    }
}
