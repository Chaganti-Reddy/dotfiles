#pragma once

#include <bits/stdc++.h>



template < class T > class lstdTreeNode
{
public:
	lstdTreeNode()
	{

	}

	lstdTreeNode( const T& t )
	{
		this->t = t;
	}

	virtual ~lstdTreeNode()
	{

	}

	void addChild( const T& t )
	{
		this->children.push_back( lstdTreeNode( t ) );
	}

	// remove a child by value, note: if the node has multiple children with the same value, this will only delete the first child
	void removeChild( const T& t )
	{
		for ( int i = 0 ; i < this->children.size() ; ++i )
		{
			if ( this->children.at(i).t == t )
			{
				this->children.erase( this->children.begin()+i );
				return;
			}
		}
	}

	void removeChildByIndex( const int index )
	{
		this->children.erase( this->children.begin()+index );
	}

	void setValue( const T& t )
	{
		this->t = t;
	}

	T& getValue()
	{
		return this->t;
	}

	const T& getValue() const
	{
		return this->t;
	}

	std::vector< lstdTreeNode >& getChildren()
	{
		return this->children;
	}

	const std::vector< lstdTreeNode >& getChildren() const
	{
		return this->children;
	}

	// the type has to have an overloaded std::ostream << operator for print to work
	void print( const int depth = 0 ) const
	{
		for ( int i = 0 ; i < depth ; ++i )
		{
			if ( i != depth-1 ) std::cout << "    ";
			else std::cout << "|-- ";
		}
		std::cout << this->t << std::endl;
		for ( uint i = 0 ; i < this->children.size() ; ++i )
		{
			this->children.at(i).print( depth+1 );
		}
	}

private:
	T t;
	std::vector< lstdTreeNode > children;
};
