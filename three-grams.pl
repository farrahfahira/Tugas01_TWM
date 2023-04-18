use Lingua::EN::Bigram;
use strict;

my $PATH = "kamus/tren";
open TOFILE, "> $PATH/3-grams.txt" or die "cant open file!!!";

my %stopwords;

load_stopwords(\%stopwords);

# ambil daftar file dari direktori yang diinginkan
my $dir = "clean/tren";
opendir(DIR, $dir) or die "Can't open directory: $!\n";
my @files = grep { /\.dat$/ } readdir(DIR);
closedir(DIR);

my $index = 0;

# proses setiap file secara terpisah
foreach my $file (@files) {
  open F, "$dir/$file" or die "Can't open input: $!\n";
  my $text = do { local $/; <F> };
  close F;

  # menghilangkan tag html
  $text =~ s/<[^>]+>//g;

  # build n-grams
  my $ngrams = Lingua::EN::Bigram->new;
  $ngrams->text( $text );

  # get tri-gram counts
  my $trigram_count = $ngrams->trigram_count;

  foreach my $trigram (sort{$$trigram_count{$b} <=> $$trigram_count{$a}} keys %$trigram_count) {

    # get the tokens of the trigram
    my ($first_token, $second_token, $third_token) = split / /, $trigram;

    # skip punctuation
    next if ( $first_token =~ /[,.?!:;()\-]/ );
    next if ( $second_token =~ /[,.?!:;()\-]/ );
    next if ( $third_token =~ /[,.?!:;()\-]/ );
    # skip stopwords;
    next if ( $stopwords{ $first_token } );
    next if ( $stopwords{ $second_token } );
    next if ( $stopwords{ $third_token } );

    $index++;

    print TOFILE "$$trigram_count{ $trigram }\t$trigram\n";

  }
}

sub load_stopwords 
{
  my $hashref = shift;
  open IN, "stopword.txt" or die "Cannot Open File!!!";
  while (<IN>)
  {
    chomp;
    if(!defined $$hashref{$_})
    {
       $$hashref{$_} = 1;
    }
  }  
}
