// C program for QuickSort
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include <graphics.h>
#include <steckschwein.h>

int max_y;
int max_x;
int titlecolors[] = { DARKGRAY, LIGHTGRAY, WHITE, LIGHTGRAY, DARKGRAY, BLACK };


// Utility function to swap tp integers
void swap(unsigned char* p1, unsigned char* p2)
{
    int temp;
    temp = *p1;
    *p1 = *p2;
    *p2 = temp;
}

void waitframes(int n)
{
    int i;
    for (i=0;i<=n;i++)
        syncvblank();
}
void setLine(int x, int val)
{
    // syncvblank();


    setcolor(BLACK);

    line(x, max_y, x, 0);

    setcolor(WHITE);
    line(x, max_y - val , x, max_y);

}
void drawArray(unsigned char arr[], int size)
{
	int i;
	for (i=0;i<=size;i++)
	{
        setLine(i, arr[i]);
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

            
            setLine(i, arr[i]);
            setLine(j, arr[j]);
            
        }
    }
    swap(&arr[i + 1], &arr[high]);

    // syncvblank();

    setLine(i+1, arr[i+1]);
    setLine(high, arr[high]);
    
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

void shuffleArray(unsigned char arr[])
{
    int i;
    for (i=0;i<max_x;i++)
    {
        arr[i]=random(max_y);
        setLine(i, arr[i]);
    }
    
}

// An optimized version of Bubble Sort
void bubbleSort(unsigned char arr[], int n)
{
	unsigned char i, j;
	bool swapped;
	for (i = 0; i < n - 1; i++) {
		swapped = false;
		for (j = 0; j < n - i - 1; j++) {
			if (arr[j] > arr[j + 1]) {
				swap(&arr[j], &arr[j + 1]);
				swapped = true;

                setLine(j, arr[j]);
                setLine(j+1, arr[j+1]);

			}
		}

		// If no two elements were swapped by inner loop,
		// then break
		if (swapped == false)
			break;
	}
}

// A function to sort the algorithm using gnome sort 
void gnomeSort(unsigned char arr[], int n) 
{ 
	int index = 0; 

	while (index < n) { 
		if (index == 0) 
			index++; 
		if (arr[index] >= arr[index - 1]) 
			index++; 
		else { 
			swap(&arr[index], &arr[index - 1]);
            setLine(index, arr[index]);
            setLine(index-1, arr[index-1]);
   
			index--; 
		} 
	} 
	return; 
} 

void cocktailSort(unsigned char arr[], int n) 
{
    bool swapped = true;
    int start = 0;
    int end = n - 1;
    int i;
    while (swapped) {
        // Move from left to right
        swapped = false;
        for (i = start; i < end; i++) {
            if (arr[i] > arr[i + 1]) {
                swap(&arr[i], &arr[i + 1]);
                

                swapped = true;
                setLine(i, arr[i]);
                setLine(i+1, arr[i+1]);

            }
        }
        if (!swapped) {
            break;
        }
        end--;
        // Move from right to left
        swapped = false;
        for (i = end - 1; i >= start; i--) {
            if (arr[i] > arr[i + 1]) {
                swap(&arr[i], &arr[i + 1]);
                swapped = true;
                setLine(i, arr[i]);
                setLine(i+1, arr[i+1]);

            }
        }
        start++;
    }
}

void titleCard(char *title, int x, int y, int delay)
{
    int i;
    cleardevice();
    for (i=0; i<6; i++)
    {
        setcolor(titlecolors[i]);
        outtextxy(x, y, title);
        waitframes(delay);
    }
}


int main()
{ 
	unsigned char arr[512];
    // int n = sizeof(arr) / sizeof(arr[0]);
    int frame_delay = 50;
    int n;
    for (;;)
    {

        initgraph(NULL, 7, NULL);
        max_y = getmaxy();
        max_x = getmaxx();
        cleardevice();
        n = max_x;


        titleCard("Sort Demo", 75, 100, 20);

        titleCard("Bubble Sort - 255 values", 50, 100, 20);
        shuffleArray(arr);   
        bubbleSort(arr, n);
        waitframes(50);

        titleCard("Cocktail Sort - 255 values", 50, 100, 20);
        shuffleArray(arr);   
        cocktailSort(arr, n);
        waitframes(50);

        titleCard("Gnome Sort - 255 values", 50, 100, 20);
        shuffleArray(arr);   
        gnomeSort(arr, n);
        waitframes(50);

        titleCard("Quick Sort - 255 values", 50, 100, 20);
        shuffleArray(arr);   
        quickSort(arr, 0, n - 1, n);
        waitframes(50);

        titleCard("Quick Sort - 512 values", 50, 100, 20);

        initgraph(NULL, 6, NULL);
        max_y = getmaxy();
        max_x = getmaxx();
        cleardevice();
        n = max_x;

        shuffleArray(arr);   
        quickSort(arr, 0, n - 1, n);
        waitframes(50);
 
    }

    // getch();
    // closegraph();
    return 0;
}
// This Code is Contributed By Diwakar Jha