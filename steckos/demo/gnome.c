// A C++ Program to implement Gnome Sort 
#include <stdio.h> 
#include <graphics.h>

// Utility function to swap tp integers
void swap(unsigned char* p1, unsigned char* p2)
{
    unsigned char temp;
    temp = *p1;
    *p1 = *p2;
    *p2 = temp;
}

// A function to sort the algorithm using gnome sort 
void gnomeSort(unsigned char arr[], unsigned char n) 
{ 
	int index = 0; 

	while (index < n) { 
		if (index == 0) 
			index++; 
		if (arr[index] >= arr[index - 1]) 
			index++; 
		else { 
			swap(&arr[index], &arr[index - 1]);


      setcolor(BLACK);
      line(index, 0, index, 212);

      setcolor(WHITE);
      line(index, 212 , index, 212- arr[index]);

      setcolor(BLACK);
      line(index-1, 0, index-1, 212);

      setcolor(WHITE);
      line(index-1, 212 , index-1, 212- arr[index-1]);

      syncvblank();

			index--; 
		} 
	} 
	return; 
} 

void drawArray(unsigned char arr[], unsigned char size)
{
	unsigned char i;
	for (i=0;i<=size;i++)
	{
		setcolor(BLACK);

		line(i, 0, i, 212);

  	setcolor(WHITE);
		line(i, 212 - arr[i], i, 212);
	}
}
// A utility function ot print an array of size n 
void printArray(unsigned char arr[], unsigned char n) 
{ 
  unsigned char i;
	printf("Sorted sequence after Gnome sort: "); 
	for (i = 0; i < n; i++) 
  {
	  printf("%d ",arr[i]); 
  }
	printf("\n"); 
} 

// Driver program to test above functions. 
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

  printf("Gnome sort\n");


  initgraph(NULL, 7, NULL);
  cleardevice();

	setcolor(WHITE);
	outtextxy(215, 10, "Gnome");
	outtextxy(215, 22, "Sort");


	drawArray(arr, n);

	gnomeSort(arr, n); 

  getch();
	return (0); 
} 
