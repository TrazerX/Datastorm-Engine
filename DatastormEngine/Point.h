#pragma once



class Point
{
public:
	Point() :m_x(0), m_y(0)
	{
	}
	Point(int x, int y) :m_x(x), m_y(y)
	{
	}
	Point(const Point& point) :m_x(point.m_x), m_y(point.m_y)
	{
	}
	~Point()
	{
	}
public:
	int m_x = 0, m_y = 0;
};