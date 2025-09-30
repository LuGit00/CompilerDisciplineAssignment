int main() {
    int x;
    int y;
    x = 10;
    y = 20;
    x = x + y;
    if (x > 15) {
        x = x - 5;
    } else {
        x = 0;
    }
    while (x < 10) {
        x = x + 1;
    }
    return x;
}