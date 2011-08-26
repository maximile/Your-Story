#include <stdlib.h>

static inline float randomFloat(float a, float b) {
    return a + (b - a) * ((float) random() / (float) RAND_MAX);
}

static inline int randomInt(int a, int b) {
    int range = b - a < 0 ? b - a - 1 : b - a + 1;
    int value = (int)(range * ((float) random() / (float) RAND_MAX));
    return value == range ? a : a + value;
}
