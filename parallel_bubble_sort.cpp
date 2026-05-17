#include <iostream>
#include <omp.h>
#include <ctime>

using namespace std;

void bubblesort(int a[], int n)
{
    for (int i = 0; i < n; i++)
    {
        int first = i % 2;

        #pragma omp parallel for shared(a, first)
        for (int j = first; j < n - 1; j += 2)
        {
            if (a[j] > a[j + 1])
            {
                int temp = a[j + 1];
                a[j + 1] = a[j];
                a[j] = temp;
            }
        }
    }

    cout << "Sorted list: (Bubble Sort)\n";

    for (int i = 0; i < n; i++)
    {
        cout << a[i] << " ";
    }
}

int main()
{
    int n = 100;

    clock_t t1, t2;

    cout << "Total number of elements: " << n << endl;

    int a[n];

    cout << "Storing elements in descending order....\n\n";

    for (int i = 0; i < n; i++)
    {
        a[i] = n - i;
    }

    cout << "Actual list:\n";

    for (int i = 0; i < n; i++)
    {
        cout << a[i] << " ";
    }

    cout << "\n";

    t1 = clock();

    bubblesort(a, n);

    t2 = clock();

    printf("\nExecution Time: %f",
           (double)(t2 - t1) / CLOCKS_PER_SEC);

    return 0;
}