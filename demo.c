float i;

int fact(int a)
{
	if(a == 0) return 1;
	return a * fact(a-1) * 1.0;
}

void nothing(int j, float i);

int def_nai(int x, int y);

int auxiliary()
{
	int x, y;
	float f, g;
	g = 2.5;
	x = 10;
	f = fact(x);
	y = fact(g);

   def_nai(x, f);
   println(fact);

	for(x = 1; x < y; x++)
	{
		f++;
	}

	if(fact(x) == f)
      println(f);

	while(x < f) x++;

	int a[10];
	a[!g] = fact(x);
	a[fact(x) % 10] = a[1] % ((f > g) + 3);
	nothing(a[1], a[11]);

   g = x + f;
   x = y + g;

   y = fact(fact(x));
   a[x * y] = 10;
   a[x * 1.0] = 5;
   f = x * y % 10 * 1.0;
	return 0;
}

void nothing(int i, float j)
{
   i = 2.5;
   j = 2.5;
	return i + j;
}
