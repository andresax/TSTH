#include <stdio.h>
#include <stdlib.h>
#include <opencv>


void SetIntValue(int *a, int l, int v)
{
 int i;
 for ( i = 0; i < l; i++ ) a[i] = v;
  return;
}

int main(int argc, char const *argv[])
{
	int height = 600, width = 800;
	int radius = 6;
	double threshold = 0.758:
	double thresholdIllumination = 1.0:
	int windowSize = 690;
	int i,j,k,z;

	int *matrix = (int*)malloc(sizeof(int)*height*width);

	SetIntValue(matrix, height*width, 1);

	for (i = radius; i < height-radius; ++i)
	{
		for (j = radius; j < width-radius; ++j)
		{
			for (k = -radius; k <= radius; ++k)
			{
				for (z = -radius; z <= radius; ++z)
				{
					//printf("i=%d;j=%d;k=%d;z=%d;idx1=%d;idx2=%d\n",i,j,k,z,i+j*height,(i+k)+(j+z)*radius);
					matrix[i+j*height] += matrix[(i+k)+(j+z)*radius];
				}
			}
		}
	}


	return 0;
}