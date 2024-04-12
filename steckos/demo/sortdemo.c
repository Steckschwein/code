// C program for QuickSort
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

#include <stdbool.h>

#include <graphics.h>
#include <steckschwein.h>

int max_y;
int max_x;
int titlecolors[] = { DARKGRAY, LIGHTGRAY, WHITE, LIGHTGRAY, DARKGRAY, BLACK };

int output[512];
// Create temp arrays
int L[512], R[512];

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
void setLine(int x, int val, char color)
{
    // syncvblank();


    setcolor(BLACK);

    line(x, max_y, x, 0);

    setcolor(color);
    line(x, max_y - val , x, max_y);

}
void drawArray(unsigned char arr[], int size, char color)
{
	int i;
	for (i=0;i<size;i++)
	{
        setLine(i, arr[i], color);
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

            
            setLine(i, arr[i], WHITE);
            setLine(j, arr[j], WHITE);
            
        }
    }
    swap(&arr[i + 1], &arr[high]);

    // syncvblank();

    setLine(i+1, arr[i+1], WHITE);
    setLine(high, arr[high], WHITE);
    
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

void shuffleArray(unsigned char arr[], int size)
{
    int i;
    for (i=0;i<size;i++)
    {
        arr[i]=random(max_y);
        setLine(i, arr[i], LIGHTGRAY);
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

                setLine(j, arr[j], WHITE);
                setLine(j+1, arr[j+1], WHITE);

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
            setLine(index, arr[index], WHITE);
            setLine(index-1, arr[index-1], WHITE);
   
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
                setLine(i, arr[i], WHITE);
                setLine(i+1, arr[i+1], WHITE);

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
                setLine(i, arr[i], WHITE);
                setLine(i+1, arr[i+1], WHITE);

            }
        }
        start++;
    }
}

/* function to sort arr using shellSort */
int shellSort(unsigned char arr[], int n)
{
    int gap;
    int i,j;
    int temp;
    // Start with a big gap, then reduce the gap
    for (gap = n/2; gap > 0; gap /= 2)
    {
        // Do a gapped insertion sort for this gap size.
        // The first gap elements a[0..gap-1] are already in gapped order
        // keep adding one more element until the entire array is
        // gap sorted 
        for (i = gap; i < n; i++)
        {
            // add a[i] to the elements that have been gap sorted
            // save a[i] in temp and make a hole at position i
            temp = arr[i];
 
            // shift earlier gap-sorted elements up until the correct 
            // location for a[i] is found            
            for (j = i; j >= gap && arr[j - gap] > temp; j -= gap)
            {
                arr[j] = arr[j - gap];
                setLine(j - gap, arr[j - gap], WHITE);
                setLine(j, arr[j], WHITE);
            }
                
             
            //  put temp (the original a[i]) in its correct location
            arr[j] = temp;
            setLine(j, arr[j], WHITE);

        }
    }
    return 0;
}

/* Function to sort an array using insertion sort*/
void insertionSort(unsigned char arr[], int n)
{
    int i, key, j;
    for (i = 1; i < n; i++) {
        key = arr[i];
        j = i - 1;

        /* Move elements of arr[0..i-1], that are
          greater than key, to one position ahead
          of their current position */
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            setLine(j+1, arr[j+1], WHITE);
            setLine(j, arr[j], WHITE);
            
            j = j - 1;
        }
        arr[j + 1] = key;
    }
}

// To heapify a subtree rooted with node i
// which is an index in arr[].
// n is size of heap
void heapify(unsigned char arr[], int N, int i)
{
    // Find largest among root,
    // left child and right child

    // Initialize largest as root
    int largest = i;

    // left = 2*i + 1
    int left = 2 * i + 1;

    // right = 2*i + 2
    int right = 2 * i + 2;

    // If left child is larger than root
    if (left < N && arr[left] > arr[largest])

        largest = left;

    // If right child is larger than largest
    // so far
    if (right < N && arr[right] > arr[largest])

        largest = right;

    // Swap and continue heapifying
    // if root is not largest
    // If largest is not root
    if (largest != i) {

        swap(&arr[i], &arr[largest]);
        setLine(i, arr[i], CYAN);
        setLine(largest, arr[largest], CYAN);
        

        // Recursively heapify the affected
        // sub-tree
        heapify(arr, N, largest);
    }
}

// Main function to do heap sort
void heapSort(unsigned char arr[], int N)
{
    int i;
    // Build max heap
    for (i = N / 2 - 1; i >= 0; i--)

        heapify(arr, N, i);

    // Heap sort
    for (i = N - 1; i >= 0; i--) {

        swap(&arr[0], &arr[i]);

        setLine(0, arr[0], WHITE);
        setLine(i, arr[i], WHITE);

        
        // Heapify root element
        // to get highest element at
        // root again
        heapify(arr, i, 0);
    }
}

// To find gap between elements
int getNextGap(int gap)
{
    // Shrink gap by Shrink factor
    gap = (gap*10)/13;
 
    if (gap < 1)
        return 1;
    return gap;
}
 
// Function to sort a[0..n-1] using Comb Sort
void combSort(unsigned char a[], int n)
{
    // Initialize gap
    int gap = n;
    int i;

    // Initialize swapped as true to make sure that
    // loop runs
    bool swapped = true;
 
    // Keep running while gap is more than 1 and last
    // iteration caused a swap
    while (gap != 1 || swapped == true)
    {
        // Find next gap
        gap = getNextGap(gap);
 
        // Initialize swapped as false so that we can
        // check if swap happened or not
        swapped = false;
 
        // Compare all elements with current gap
        for (i=0; i<n-gap; i++)
        {
            if (a[i] > a[i+gap])
            {
                swap(&a[i], &a[i+gap]);
                setLine(i, a[i], WHITE);
                setLine(i+gap, a[i+gap], WHITE);
                
                swapped = true;
            }
        }
    }
}

void selectionSort(unsigned char arr[], int n) 
{ 
    int i, j, min_idx; 
  
    // One by one move boundary of unsorted subarray 
    for (i = 0; i < n-1; i++) 
    { 
        // Find the minimum element in unsorted array 
        min_idx = i; 
        for (j = i+1; j < n; j++) 
          if (arr[j] < arr[min_idx]) 
            min_idx = j; 
  
        // Swap the found minimum element with the first element 
           if(min_idx != i) 
           {

                swap(&arr[min_idx], &arr[i]); 
                setLine(min_idx, arr[min_idx], WHITE);
                setLine(i, arr[i], WHITE);
           }
    } 
} 

// A utility function to get maximum
// value in arr[]
int getMax(unsigned char arr[], int n)
{
    int i;
    int mx = arr[0];
    for (i = 1; i < n; i++)
        if (arr[i] > mx)
            mx = arr[i];
    return mx;
}
 
// A function to do counting sort of arr[]
// according to the digit
// represented by exp.
void countSort(unsigned char arr[], int n, int exp)
{
 
    // Output array
    int i, count[10] = { 0 };
 
    // Store count of occurrences
    // in count[]
    for (i = 0; i < n; i++)
        count[(arr[i] / exp) % 10]++;
 
    // Change count[i] so that count[i]
    // now contains actual position
    // of this digit in output[]
    for (i = 1; i < 10; i++)
        count[i] += count[i - 1];
 
    // Build the output array
    for (i = n - 1; i >= 0; i--) {
        output[count[(arr[i] / exp) % 10] - 1] = arr[i];
       
        count[(arr[i] / exp) % 10]--;
    }
 
    // Copy the output array to arr[],
    // so that arr[] now contains sorted
    // numbers according to current digit
    for (i = 0; i < n; i++)
    {
        arr[i] = output[i];
        setLine(i, arr[i], WHITE);
    }
}
 
// The main function to that sorts arr[]
// of size n using Radix Sort
void radixsort(unsigned char arr[], int n)
{
    int exp;
    // Find the maximum number to
    // know number of digits
    int m = getMax(arr, n);
    
    // Do counting sort for every digit.
    // Note that instead of passing digit
    // number, exp is passed. exp is 10^i
    // where i is current digit number
    for (exp = 1; m / exp > 0; exp *= 10)
        countSort(arr, n, exp);
}

// Merges two subarrays of arr[].
// First subarray is arr[l..m]
// Second subarray is arr[m+1..r]
void merge(unsigned char arr[], int l, int m, int r)
{
    int i, j, k;
    int n1 = m - l + 1;
    int n2 = r - m;

    // // Create temp arrays
    // int L[512], R[512];

    // Copy data to temp arrays L[] and R[]
    for (i = 0; i < n1; i++)
        L[i] = arr[l + i];
    for (j = 0; j < n2; j++)
        R[j] = arr[m + 1 + j];

    // Merge the temp arrays back into arr[l..r
    i = 0;
    j = 0;
    k = l;
    while (i < n1 && j < n2) {
        if (L[i] <= R[j]) {
            arr[k] = L[i];
            i++;
        }
        else {
            arr[k] = R[j];
            j++;
        }
        setLine(k, arr[k], WHITE);
        k++;
    }

    // Copy the remaining elements of L[],
    // if there are any
    while (i < n1) {
        arr[k] = L[i];
        i++;
        k++;
    }

    // Copy the remaining elements of R[],
    // if there are any
    while (j < n2) {
        arr[k] = R[j];
        j++;
        k++;
    }
}

// l is for left index and r is right index of the
// sub-array of arr to be sorted
void mergeSort(unsigned char arr[], int l, int r)
{
    if (l < r) {
        int m = l + (r - l) / 2;

        // Sort first and second halves
        mergeSort(arr, l, m);
        mergeSort(arr, m + 1, r);

        merge(arr, l, m, r);
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
    int n;
    int frame_delay = 50;
    char key;
    while (kbhit() != KEY_ESCAPE)
    {

        initgraph(NULL, 7, NULL);
        max_y = getmaxy();
        max_x = getmaxx();
        cleardevice();
        n = 64;


        titleCard("Sort Demo", 90, 100, 20);

        titleCard("Bubble Sort - 64 values", 40, 100, 20);
        shuffleArray(arr, n);   
        bubbleSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Cocktail Sort - 64 values", 30, 100, 20);
        shuffleArray(arr, n);   
        cocktailSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Gnome Sort - 64 values", 50, 100, 20);
        shuffleArray(arr, n);   
        gnomeSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Insertion Sort - 64 values", 30, 100, 20);        
        shuffleArray(arr, n);   
        insertionSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        n = max_x;

        titleCard("Comb Sort - 255 values", 50, 100, 20);
        shuffleArray(arr, n);   
        combSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);


        titleCard("Heap Sort - 255 values", 50, 100, 20);
        shuffleArray(arr, n);   
        heapSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Shell Sort - 255 values", 50, 100, 20);
        shuffleArray(arr, n);   
        shellSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Selection Sort - 255 values", 30, 100, 20);        
        shuffleArray(arr, n);   
        selectionSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Quick Sort - 255 values", 50, 100, 20);
        shuffleArray(arr, n);   
        quickSort(arr, 0, n - 1, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Merge Sort - 255 values", 40, 100, 20);
        shuffleArray(arr, n);   
        mergeSort(arr, 0, n-1);
        drawArray(arr, n, GREEN);
        waitframes(50);




        initgraph(NULL, 6, NULL);
        max_y = getmaxy();
        max_x = getmaxx();
        cleardevice();
        n = max_x;

        titleCard("Quick Sort - 512 values", 50, 100, 20);
       
        shuffleArray(arr, n);   
        quickSort(arr, 0, n - 1, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Shell Sort - 512 values", 50, 100, 20);
        shuffleArray(arr, n);   
        shellSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Selection Sort - 512 values", 30, 100, 20);        
        shuffleArray(arr, n);   
        selectionSort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Merge Sort - 512 values", 40, 100, 20);
        shuffleArray(arr, n);   
        mergeSort(arr, 0, n-1);
        drawArray(arr, n, GREEN);
        waitframes(50);

        titleCard("Radix Sort - 512 values", 50, 100, 20);        
        shuffleArray(arr, n);   
        radixsort(arr, n);
        drawArray(arr, n, GREEN);
        waitframes(50);

    }

    closegraph();
            
    return 0;
}