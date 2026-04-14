#include <iostream>

using namespace std;
extern "C" double MiPow(double x, double y);

int main() {
    double x, y, r;

    cout << "Programa que realiza la funcion pow(x,y)" << endl;
    cout << R"(----- CON EL USO DE LA FPU -----)" << endl;

    cout << "Ingresa X: ";
    cin >> x;

    cout << "Ingresa Y: ";
    cin >> y;

    r = MiPow(x, y);

    cout << "\nEl resultado de " << x << " elevado a " << y << " es: " << r << endl;

    return 0;
}