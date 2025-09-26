int main() {
    int x = 10;
    float y = 20.5;
    x = x + (int)y;
    if (x > 20) {
        return x;
    } else {
        return 0;
    }
    while (x < 100) {
        x = x + 1;
    }
    return 0;
}