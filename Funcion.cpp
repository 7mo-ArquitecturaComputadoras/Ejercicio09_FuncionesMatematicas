#include <iostream>

using namespace std;
extern "C" double Mi_pow(double x, double y);
extern "C" double Mi_sqrt(double x);
extern "C" double Mi_fact(double x);

int main() {
    double x, y, r;

    cout << "Programa que realiza la funcion pow(x,y)" << endl;
    cout << R"(----- CON EL USO DE LA FPU -----)" << endl;

    cout << "Ingresa X: ";
    cin >> x;

    cout << "Ingresa Y: ";
    cin >> y;

    r = Mi_pow(x, y);

    cout << "\npow( " << x << " , " << y << " ) = " << r << endl;

    r = Mi_sqrt(x);

    cout << "\nsqrt( " << x << " ) = " << r << endl;

    r = Mi_fact(x);

    cout << "\nfact( " << x << " ) = " << r << endl;
    return 0;
}