/* I can't find a way to make it work with accented letters
 * And performs worst than order approaches with Python, AWK
 * and other UNIX utilities without copiler optmizations.
 */

#include <iostream>
#include <fstream>
#include <regex>
#include <unordered_map>
#include <boost/algorithm/string.hpp>

using namespace std;

int main(int argc, char const *argv[])
{
    unordered_map<string, unsigned int> words;
    const regex re("[[:alpha:]]+(-[:alpha:]+)?", regex::egrep);
    string word_raw,    // Text with unliked characters
           word_cooked; // Trustworthy word
    ifstream file;
    
    file.open(argv[1]);
    
    if ( ! file.is_open() ) return 1;
        
    while (file >> word_raw) {
        smatch match;
        regex_search(word_raw, match, re);
        
        if (match.size()) {
            word_cooked = boost::to_lower_copy(match.str(0));
            words[word_cooked]++;
        }
    }
        
    file.close();

    for (auto& word : words) {
        cout << word.first << ":" << word.second << endl;
    }

    return 0;
}