// C program for QuickSort
#include <stdio.h>
#include <graphics.h>


// Utility function to swap tp integers
void swap(unsigned char* p1, unsigned char* p2)
{
    int temp;
    temp = *p1;
    *p1 = *p2;
    *p2 = temp;
}

// Function to print an array
void printArray(unsigned char arr[], unsigned char size)
{
	unsigned char i;
	printf("\n");
	for (i = 0; i < size; i++)
		printf("%d ", arr[i]);
}

void drawArray(unsigned char arr[], unsigned char size)
{
	unsigned char i;
	for (i=0;i<=size;i++)
	{
		setcolor(BLUE);

		line(i, 0, i, 212);

  	    setcolor(WHITE);
		line(i, 212 - arr[i], i, 212);
	}
}

int partition(unsigned char arr[], unsigned char low, unsigned char high)
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
            setcolor(BLUE);

            line(i, 0, i, 255);

            setcolor(WHITE);
            // line(i, 0, i, arr[i]);

            // line(i, 212 - arr[i], i, 212);
            line(i, 212 , i, 212- arr[i]);
            



            setcolor(BLUE);

            line(j, 0, j, 212);

            setcolor(WHITE);
            // line(j, 0, j, arr[j]);
            // line(j, 212 - arr[j], j, 212);
            line(j, 212, j, 212 - arr[j]);

        }
    }
    swap(&arr[i + 1], &arr[high]);

    syncvblank();
    setcolor(BLUE);

    line(i+1, 0, i+1, 212);

    setcolor(WHITE);
    // line(i+1, 0, i+1, arr[i+1]);
    line(i+1, 212 - arr[i+1], i+1, 212);



    setcolor(BLUE);

    line(high, 0, high, 212);

    setcolor(WHITE);
    // line(high, 0, high, arr[high]);
    line(high, 212, high, 212 - arr[high]);


    return (i + 1);
}

// The Quicksort function Implement

void quickSort(unsigned char arr[], unsigned char low, unsigned char high, unsigned char n)
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
	unsigned char arr[] = {
51, 213, 73, 124, 186, 42, 127, 107, 138, 151, 6, 128, 55, 208, 156, 30, 57, 108, 14, 225, 104, 93, 
170, 65, 53, 160, 56, 49, 243, 81, 179, 131, 110, 103, 26, 237, 188, 54, 1, 154, 29, 139, 92, 21, 254, 
155, 148, 79, 76, 100, 60, 212, 129, 190, 145, 91, 231, 245, 165, 125, 201, 205, 2, 246, 109, 69, 134, 
207, 31, 177, 215, 149, 196, 105, 234, 123, 200, 233, 27, 3, 152, 130, 118, 32, 192, 236, 99, 211, 250,
140, 10, 71, 48, 206, 84, 78, 248, 244, 74, 20, 70, 239, 45, 114, 52, 36, 157, 50, 67, 16, 146, 5, 72,
171, 68, 116, 87, 120, 66, 172, 228, 176, 115, 214, 251, 229, 147, 216, 137, 191, 11, 85, 17, 161, 185, 
19, 82, 95, 136, 126, 252, 41, 15, 44, 121, 38, 241, 164, 9, 35, 47, 97, 113, 83, 197, 135, 111, 187, 249, 
106, 219, 117, 40, 163, 193, 158, 102, 181, 253, 8, 204, 184, 182, 203, 142, 23, 77, 183, 37, 167, 224, 
202, 222, 218, 220, 178, 4, 198, 230, 122, 240, 132, 194, 232, 43, 98, 242, 221, 39, 62, 63, 195, 210,
227, 75, 153, 133, 112, 96, 94, 235, 189, 141 }; 
    unsigned char n = sizeof(arr) / sizeof(arr[0]);
    unsigned char i;

	initgraph(NULL, 7, NULL);
    cleardevice();


	// printf("Unsorted array: \n");
	// printArray(arr, n);
	drawArray(arr, n);


    // printf("Unsorted Array\n");
    // printArray(arr, n);
    

    // Function call
    quickSort(arr, 0, n - 1, n);
    
  // Print the sorted array
    // printf("\nSorted Array\n");
    // printArray(arr, n);
    getch();
    return 0;
}
// This Code is Contributed By Diwakar Jha