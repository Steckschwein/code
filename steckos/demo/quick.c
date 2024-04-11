// C program for QuickSort
#include <stdio.h>
#include <stdlib.h>
#include <graphics.h>


// Utility function to swap tp integers
void swap(unsigned char* p1, unsigned char* p2)
{
    int temp;
    temp = *p1;
    *p1 = *p2;
    *p2 = temp;
}

void drawArray(unsigned char arr[], int size)
{
	int i;
	for (i=0;i<=size;i++)
	{
		setcolor(BLACK);

		line(i, 20, i, 212);

  	    setcolor(WHITE);
		line(i, 212 - arr[i] +20, i, 212);
	}
}

int partition(unsigned char arr[], int low, int high)
{
    // choose the pivot
    int pivot = arr[high];
    int j;

    // Index of smaller element and Indicate
    // the right position of pivot found so far
    int i = (low - 1);

    for (j = low; j <= high; j++) {
        // If current element is smaller than the pivot
        if (arr[j] < pivot) {
            // Increment index of smaller element
            i++;
            swap(&arr[i], &arr[j]);

            syncvblank();
            setcolor(BLACK);

            line(i, 20, i, 255);

            setcolor(WHITE);
            line(i, 212 , i, 212- arr[i] + 20);
            

            setcolor(BLACK);

            line(j, 20, j, 212);

            setcolor(WHITE);
            line(j, 212, j, 212 - arr[j] + 20);

        }
    }
    swap(&arr[i + 1], &arr[high]);

    // syncvblank();
    setcolor(BLACK);

    line(i+1, 20, i+1, 212);

    setcolor(WHITE);
    line(i+1, 212 - arr[i+1] + 20, i+1, 212);



    setcolor(BLACK);

    line(high, 20, high, 212);

    setcolor(WHITE);
    line(high, 212, high, 212 - arr[high] + 20);


    return (i + 1);
}

// The Quicksort function Implement

void quickSort(unsigned char arr[], int low, int high, int n)
{
    // when low is less than high
    if (low < high) {
        // pi is the partition return index of pivot

        int pi = partition(arr, low, high);

        // Recursion Call
        // smaller element than pivot goes left and
        // higher element goes right
        quickSort(arr, low, pi - 1, n);
        quickSort(arr, pi + 1, high, n);
    }
}

int main()
{ 
	unsigned char arr[512];
    int n = sizeof(arr) / sizeof(arr[0]);

    int i;
   
    for (i=0;i<512;i++)
    {
        arr[i]=random(200);
    }
    
    initgraph(NULL, 6, NULL);
    cleardevice();

    setcolor(WHITE);
    outtextxy(0, 10, "Quick Sort");
	


	drawArray(arr, n);

    quickSort(arr, 0, n - 1, n);
    
    getch();
    closegraph();
    return 0;
}
// This Code is Contributed By Diwakar Jha