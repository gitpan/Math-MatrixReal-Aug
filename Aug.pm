#package Math::MatrixReal::Aug;
package Math::MatrixReal;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Math::MatrixReal::Aug ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);
our $VERSION = '0.01';


# Preloaded methods go here.
use Carp;
use overload
    'x' => 'augmentright',
    '.' => 'augmentbelow';

sub augmentright {
    #$left->augmentright($right)
    #returns the matrix [$left $right], if the number of rows are the same
    my ($left, $right,$flag)=@_;
    croak "Usage: \$matrix1->augmentright(\$matrix2)" if (@_ < 2);
    my ($leftrows, $leftcols)  = $left->dim();
    my ($rightrows, $rightcols)  = $right->dim();
    croak "Math::MatrixReal::augmentright() size mismatch" if ($leftrows != $rightrows);
    my($i,$j);
    my $bigmatrix= new Math::MatrixReal($leftrows, $leftcols+$rightcols);
    for ($i=1;$i<=$leftrows;$i++){
        for($j=1;$j<=$leftcols;$j++){
            $bigmatrix->assign($i,$j,$left->element($i,$j));
        }
        for($j=1;$j<=$rightcols;$j++){
            $bigmatrix->assign($i,$j+$leftcols,$right->element($i,$j));
        }
    }
    return $bigmatrix;

}



sub augmentbelow {
    #$top->augmentbelow($bottom)
    #returns the matrix [$top $bottom], if the number of rows are the same
    my ($top, $bottom)=@_;
    croak "Usage: \$matrix1->augmentbottom(\$matrix2)" if (@_ < 2);
    my ($toprows, $topcols)  = $top->dim();
    my ($bottomrows, $bottomcols)  = $bottom->dim();
    croak "Math::MatrixReal::augmentbottom() size mismatch" if ($topcols != $bottomcols);
    my $bigmatrix = new Math::MatrixReal($toprows+$bottomrows, $topcols);
    my($i,$j);
    for($j=1;$j<=$topcols;$j++){
        for($i=1;$i<=$toprows;$i++){
            $bigmatrix->assign($i,$j,$top->element($i,$j));
        }
        for($i=1;$i<=$bottomrows;$i++){
            $bigmatrix->assign($i+$toprows,$j,$bottom->element($i,$j));
        }
    }
    return $bigmatrix;

}

sub applyfunction {
    
    my ($matrix, $funcref)=@_;
    my($i,$j);
    my($rows,$cols)=$matrix->dim();
    my $rangematrix=new Math::MatrixReal($rows,$cols);
    for($i=1;$i<=$rows;$i++){
	for($j=1;$j<=$cols;$j++){
	    $rangematrix->assign($i,$j,&$funcref($matrix,$matrix->element($i,$j),$i,$j));
	}
    }
    return $rangematrix;
    
}


sub largeexponential {
    #find matrix^exponent using the square-and-multiply method
    my ($matrix,$exponent,@extra)=@_;
    croak "Math::MatrixReal::largeexponential matrix must be square" unless $matrix->is_square();
    croak "Math::MatrixReal::largeexponential exponent must be positive" unless $exponent>0;
    croak "Math::MatrixReal::largeexponential exponent must be integer" unless ($exponent =~ m/^[+]?\d+$/ );
    return $matrix unless $exponent;
    #get a representation of $exponent in binary
    my $bitstr = unpack('B32',pack('N',$exponent));
    $bitstr =~s/^0*//;
    my @bitstr=split(//,$bitstr);
    my $z=$matrix->shadow();
    $z->one();
    foreach my $bit (@bitstr){
        $z = ($z*$z);
        if ($bit){
            $z = ($z*$matrix);
        }
    }
    return $z;
}


sub fill {
    my ($object, $const) = @_;
    my ($rows, $cols) = $object->dim();
    for my $i (1..$rows) {
	for my $j (1..$cols) {
	    $object->assign($i,$j,$const);
	}
    }
    return;
}

sub newfill {
    croak "Usage: \$new_matrix = Math::MatrixReal->newfill(\$rows,\$columns,\$constant);"
      if (@_ != 4);

    my ($proto,$rows,$cols,$constant) =  @_;
    my $class = ref($proto) || $proto || 'Math::MatrixReal';
    my($i,$j,$this);

    croak "Math::MatrixReal::newfill(): number of rows must be integer > 0"
      unless ($rows > 0 and  $rows == int($rows) );

    croak "Math::MatrixReal::newfill(): number of columns must be integer > 0"
      unless ($cols > 0 and $cols == int($cols) );
    $this = new Math::MatrixReal($rows,$cols);
    $this->fill($constant);
    return $this;
}

1;



1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Math::MatrixReal::Aug - Additional methods for Math::MatrixReal.

=head1 SYNOPSIS

  use Math::MatrixReal;
  use Math::MatrixReal::Aug;


=head1 DESCRIPTION

These are certain extra methods for Math::MatrixReal, in the tradition 
of Math::MatrixReal::Ext1;

=over 4

=item *

C<$matrix1-E<gt>augmentright($matrix2);>

Creates a new matrix of the form [$matrix1 $matrix2]. $matrix1 and
$matrix2 must have the same number of rows.

Example:

 $A = Math::MatrixReal->new_from_cols([[1,0]]);
 $B = Math::MatrixReal->new_from_cols([[1,2],[2,1]]);

 $C = $A / $B
 print $C;
 [  1.000000000000E+00  1.000000000000E+00  2.000000000000E+00 ]
 [  0.000000000000E+00  2.000000000000E+00  1.000000000000E+00 ]

=item *

C<$matrix1-E<gt>augmentbelow($matrix2);>

Creates a new matrix of the form 
 [ $matrix1 ]
 [ $matrix2 ]. 
$matrix1 and $matrix2 must have the same number of columns.

Example:

 $A = Math::MatrixReal->new_from_cols([[1,0],[0,1]]);
 $B = Math::MatrixReal->new_from_cols([[1,2],[2,1]]);

 $C = $A / $B
 print $C;
 [  1.000000000000E+00  0.000000000000E+00 ]
 [  0.000000000000E+00  1.000000000000E+00 ]
 [  1.000000000000E+00  2.000000000000E+00 ]
 [  2.000000000000E+00  1.000000000000E+00 ]


=item *

C<$matrix-E<gt>applyfunction($coderef)>

Applies &$coderef to each element of $matrix, and returns the result.
$coderef should be a reference to a subroutine that takes four parameters:
($matrix, $matrix->element($i,$j), $i, $j) where $i and $j are the row and
column indices of the current element.

Example:

 sub increment {
     my ($matrix,$element, $i,$j)=@_;
     return $element+1;
 }

 $A = Math::MatrixReal->new_from_cols([[1,0],[0,1]]);

 $E=$A->applyfunction(\&increment);
 print $E;
 [  2.000000000000E+00  1.000000000000E+00 ]
 [  1.000000000000E+00  2.000000000000E+00 ]

=item *

C<$matrix-E<gt>largeexponential($exponent)>

Finds $matrix^$exponent using the square-and-multiply method.  
$matrix must be square and $exponent must be a positive integer. 
Much more efficient for large $exponent than $matrix->$exponential($exponent)
in that approximately log2($exponent) multiplications are required
instead of approximately $exponent.

=item * 

C<$matrix-E<gt>fill($const);>

Sets all elements of $matrix equal to $const.

Example: 

 $A = new Math::MatrixReal(3,3);
 $A->fill(4);
 print $A;
 [  4.000000000000E+00  4.000000000000E+00  4.000000000000E+00 ]
 [  4.000000000000E+00  4.000000000000E+00  4.000000000000E+00 ]
 [  4.000000000000E+00  4.000000000000E+00  4.000000000000E+00 ]

=item * 

C<< $new_matrix = $some_matrix->newfill($rows,$columns,$const); >>
C<< $new_matrix = Math::MatrixReal->newfill($rows,$columns,$const); >>


Creates a new matrix of the specified size, all the elements of
which are $const.

Example: 

 $A = Math::MatrixReal->newfill(3,3,4);
 print $A;
 [  4.000000000000E+00  4.000000000000E+00  4.000000000000E+00 ]
 [  4.000000000000E+00  4.000000000000E+00  4.000000000000E+00 ]
 [  4.000000000000E+00  4.000000000000E+00  4.000000000000E+00 ]

=back

=head1 OVERLOADED OPERATORS

=head2 New Binary operators:

C<x>, C<.>

=over 4

=item C<< x >>

Right augmenting binary operator.  

 $A x $B 
is the same as 
 $A->augmentright($B)

=item C<< . >>

Bottom augmenting binary operator.     

 $A . $B  
is the same as 
 $A->augmentbelow($B)

=back

=head1 NOTES

The augmentright operator has a higher precence than the augmentbelow
operator, so $A x $B . $B x $A is 
 [ $A $B ]
 [ $B $A ]

=head1 BUGS

Provably countably infinite.  

This document can be improved.

No testing routines are provided.  

=head1 AUTHOR

Jacob C. Kesinger, E<lt>kesinger@math.ttu.eduE<gt>

=head1 SEE ALSO

L<Math::MatrixReal>.

=cut
