// C program for QuickSort
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <conio.h>

#include <stdbool.h>

#include <graphics.h>
#include <steckschwein.h>

#define SORT_BUFFER_SIZE 512

int max_y;
int max_x;
int titlecolors[] = { DARKGRAY, LIGHTGRAY, WHITE, LIGHTGRAY, DARKGRAY, BLACK };
int frame_delay = 50;

typedef struct { char *key; char *name; int num; void (*func)(int); } t_sortstruct;
typedef unsigned char uint8;

    

// main sort array
unsigned char arr[SORT_BUFFER_SIZE];

// Create temp arrays
unsigned char arr_tmp1[SORT_BUFFER_SIZE], arr_tmp2[SORT_BUFFER_SIZE];

// Utility function to swap tp integers
int temp;
void swap(unsigned char* p1, unsigned char* p2)
{
    temp = *p1;
    *p1 = *p2;
    *p2 = temp;

    // *p1 = *p1 ^ *p2;
    // *p2 = *p1 ^ *p2;
    // *p1 = *p1 ^ *p2;

}

void waitframes(int n)
{
    uint8 i;
    for (i=0;i<=n;i++)
        syncvblank();
}

void setLine(int x, uint8 val, char color)
{
    // syncvblank();


    setcolor(BLACK);

    line(x, max_y, x, 0);

    setcolor(color);
    line(x, max_y - val , x, max_y);

}
void drawArray(int size, char color)
{
	int i;
	for (i=0;i<size;i++)
	{
        setLine(i, arr[i], color);
	}
}
void shuffleArray(int size)
{
    int i;
    for (i=0;i<size;i++)
    {
        arr[i]=random(max_y);
        setLine(i, arr[i], LIGHTGRAY);
    }   
}

int partition(int low, int high)
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

void quickSort(int low, int high, int n)
{
    // when low is less than high
    if (low < high) {
        // pi is the partition return index of pivot

        int pi = partition(low, high);

        // Recursion Call
        // smaller element than pivot goes left and
        // higher element goes right
        quickSort(low, pi - 1, n);
        quickSort(pi + 1, high, n);
    }
}


// An optimized version of Bubble Sort
void bubbleSort(int n)
{
	int i, j;
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
void gnomeSort(int n) 
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

void cocktailSort(int n) 
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
void shellSort(int n)
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
    return;
}

/* Function to sort an array using insertion sort*/
void insertionSort(int n)
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
void heapify(int N, int i)
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
        heapify(N, largest);
    }
}

// Main function to do heap sort
void heapSort(int N)
{
    int i;
    // Build max heap
    for (i = N / 2 - 1; i >= 0; i--)

        heapify(N, i);

    // Heap sort
    for (i = N - 1; i >= 0; i--) {

        swap(&arr[0], &arr[i]);

        setLine(0, arr[0], WHITE);
        setLine(i, arr[i], WHITE);

        
        // Heapify root element
        // to get highest element at
        // root again
        heapify(i, 0);
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
void combSort(int n)
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
            if (arr[i] > arr[i+gap])
            {
                swap(&arr[i], &arr[i+gap]);
                setLine(i, arr[i], WHITE);
                setLine(i+gap, arr[i+gap], WHITE);
                
                swapped = true;
            }
        }
    }
}

void selectionSort(int n) 
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
uint8 getMax(int n)
{
    int i;
    uint8 mx = arr[0];
    for (i = 1; i < n; i++)
        if (arr[i] > mx)
            mx = arr[i];
    return mx;
}
 
// A function to do counting sort of arr[]
// according to the digit
// represented by exp.
void countSort(int n, int exp)
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
        arr_tmp1[count[(arr[i] / exp) % 10] - 1] = arr[i];
       
        count[(arr[i] / exp) % 10]--;
    }
 
    // Copy the output array to arr[],
    // so that arr[] now contains sorted
    // numbers according to current digit
    for (i = 0; i < n; i++)
    {
        arr[i] = arr_tmp1[i];
        setLine(i, arr[i], WHITE);
    }
}
 
// The main function to that sorts arr[]
// of size n using Radix Sort
void radixsort(int n)
{
    int exp;
    // Find the maximum number to
    // know number of digits
    int m = getMax(n);
    
    // Do counting sort for every digit.
    // Note that instead of passing digit
    // number, exp is passed. exp is 10^i
    // where i is current digit number
    for (exp = 1; m / exp > 0; exp *= 10)
        countSort(n, exp);
}

// Merges two subarrays of arr[].
// First subarray is arr[l..m]
// Second subarray is arr[m+1..r]
void merge(int l, int m, int r)
{
    int i, j, k;
    int n1 = m - l + 1;
    int n2 = r - m;

    // // Create temp arrays
    // int L[512], R[512];

    // Copy data to temp arrays L[] and R[]
    for (i = 0; i < n1; i++)
        arr_tmp1[i] = arr[l + i];
    for (j = 0; j < n2; j++)
        arr_tmp2[j] = arr[m + 1 + j];

    // Merge the temp arrays back into arr[l..r
    i = 0;
    j = 0;
    k = l;
    while (i < n1 && j < n2) {
        if (arr_tmp1[i] <= arr_tmp2[j]) {
            arr[k] = arr_tmp1[i];
            i++;
        }
        else {
            arr[k] = arr_tmp2[j];
            j++;
        }
        setLine(k, arr[k], WHITE);
        k++;
    }

    // Copy the remaining elements of L[],
    // if there are any
    while (i < n1) {
        arr[k] = arr_tmp1[i];
        i++;
        k++;
    }

    // Copy the remaining elements of R[],
    // if there are any
    while (j < n2) {
        arr[k] = arr_tmp2[j];
        j++;
        k++;
    }
}

// l is for left index and r is right index of the
// sub-array of arr to be sorted
void mergeSort(int l, int r)
{
    if (l < r) {
        int m = l + (r - l) / 2;

        // Sort first and second halves
        mergeSort(l, m);
        mergeSort(m + 1, r);

        merge(l, m, r);
    }
}

  
void titleCard(char *title, int delay)
{
    int i;
   
    int x = (int)(255 - strlen(title) * 8) / 2;


    cleardevice();
    for (i=0; i<6; i++)
    {
        setcolor(titlecolors[i]);
        outtextxy(x, 100, title);
        waitframes(delay);
    }
}

void mergeSortWrapper(int n)
{
    mergeSort(0, n-1);
}

void quickSortWrapper(int n)
{
    quickSort(0, n - 1, n);
}

static t_sortstruct lookuptable[] = {
    { "bubble",    "Bubble",       64, bubbleSort}, 
    { "cocktail",  "Cocktail",     64, cocktailSort }, 
    { "insertion", "Insertion",    64, insertionSort }, 
    { "gnome",     "Gnome",        64, gnomeSort },
    { "comb",      "Comb",         255, combSort },
    { "selection", "Selection",    255, selectionSort },
    { "quick",     "Quick",        255, quickSortWrapper },
    { "merge",     "Merge",        255, mergeSortWrapper },
    { "radix",     "Radix",        255, radixsort },
    { "quick512",  "Quick",        512, quickSortWrapper },
    { "merge512",  "Merge",        512, mergeSortWrapper },
    { "radix512",  "Radix",        512, radixsort }
};

#define NKEYS (sizeof(lookuptable)/sizeof(t_sortstruct))


char title[50];
void runSort(char * name, void (*ptr)(int), int n, bool wait)
{
        uint8 graphmode = 7;

        if (n>255)
        {
            graphmode = 6;
        }
        initgraph(NULL, graphmode, NULL);
        max_y = getmaxy();
        max_x = getmaxx();
        cleardevice();


        snprintf(title, 50, "%s Sort - %d values", name, n);


        titleCard(title, 20);
        shuffleArray(n);   
        (*ptr)(n);

        drawArray(n, GREEN);
        if (wait)
        {
            getch();
        }
}

void loop()
{
    // char key;
    // int n;
    while (kbhit() != KEY_ESCAPE)
    {
        unsigned char i;

        initgraph(NULL, 7, NULL);
        max_y = getmaxy();
        max_x = getmaxx();
        cleardevice();

        titleCard("Sort Demo", 20);

        for (i=0;i<NKEYS;i++)
        {
            printf("%s\n", lookuptable[i].name);
            runSort(lookuptable[i].name, lookuptable[i].func, lookuptable[i].num, false);
            waitframes(50);
        }
    }
 
}



t_sortstruct * funcfromstring(char *key)
{
    uint8 i;
    for (i=0; i < NKEYS; i++) {
        t_sortstruct *sym = &lookuptable[i];
        if (strcmp(sym->key, key) == 0)
        {
            return sym;
        }
    }
    return NULL;
}
int main(int argc, char *argv[])
{ 
    int n;
    t_sortstruct * sort;



    if (argc >= 2)
    {
        sort = funcfromstring(argv[1]);
        if (sort == NULL)
        {
            printf("Unknown sort '%s'. Possible values: bubble, cocktail, gnome, insert, comb, heap, shell, selection, quick, merge, radix", argv[1]);
            return 1;
        }

        if (argc >= 3)
        {
            n = atoi(argv[2]);
            if (n > 512)
            {
                printf("Too many values.\n");
                return 1;
            }
        }
        else
        {
            n = sort->num;
        }

        runSort(sort->name, sort->func, n, true);
        closegraph();
        return 0;
    }
    loop();
    closegraph();

    return 0;
}