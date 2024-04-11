// Optimized implementation of Bubble sort
#include <stdbool.h>
#include <stdio.h>
#include <graphics.h>


void swap(unsigned char* xp, unsigned char* yp)
{
	unsigned char temp = *xp;
	*xp = *yp;
	*yp = temp;
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



// An optimized version of Bubble Sort
void bubbleSort(unsigned char arr[], unsigned char n)
{
	unsigned char i, j;
	bool swapped;
	for (i = 0; i < n - 1; i++) {
		swapped = false;
		for (j = 0; j < n - i - 1; j++) {
			if (arr[j] > arr[j + 1]) {
				swap(&arr[j], &arr[j + 1]);
				swapped = true;
				syncvblank();

				setcolor(BLUE);

				line(j, 0, j, 212);

				setcolor(WHITE);
				line(j, 212 - arr[j], j, 212);


				setcolor(BLUE);

				line(j+1, 0, j+1, 212);

				setcolor(WHITE);
				line(j+1, 212 - arr[j+1], j+1, 212);

			}
		}

		// If no two elements were swapped by inner loop,
		// then break
		if (swapped == false)
			break;
	}
}


// Driver program to test above functions
unsigned char main()
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
	
	initgraph(NULL, 7, NULL);

  cleardevice();


	drawArray(arr, n);

	bubbleSort(arr, n);
	getch();

	return 0;
}
