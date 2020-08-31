/*
#### DEVELOPED BY #ZAANG! TEAM ####
-> All functions and algorithms have their own description.
-> The code has a debug feature, in case the whole process of learning the code is necessary.
-> The code is pure hard-working job from the team.
-> The Language selected for description is English.
*/

// include/define of needed dependencies
#include <algorithm>
#include <array>
#include <algorithm>
#include <locale>
#include <iterator>
#include <iostream> 
#include <iomanip>
#include <map>
#include <sstream>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <cmath>
#include <time.h>
#include <bitset>
#include <stdint.h>
#include <vector>
#define ull unsigned long long int
typedef uint8_t GLF6; /* Galois field of order 2^6 */
typedef std::vector<GLF6> GLF6Polynomial;
// end include/define

using namespace std;

const bool debug = true; //if needed debug, change to true

// maps, vectors and arrays (const dictionaries)
const GLF6 alpha = 2;
const int initpwr = 1;
const GLF6 field = 64;
const map<const string, int> barsDecimal{ {"FFF",0},{"FFA",1},{"FFD",2},{"FFT",3},{"FAF",4},{"FAA",5},{"FAD",6},{"FAT",7},{"FDF",8},{"FDA",9},{"FDD",10},{"FDT",11},{"FTF",12},{"FTA",13},{"FTD",14},{"FTT",15},{"AFF",16},{"AFA",17},{"AFD",18},{"AFT",19},{"AAF",20},{"AAA",21},{"AAD",22},{"AAT",23},{"ADF",24},{"ADA",25},{"ADD",26},{"ADT",27},{"ATF",28},{"ATA",29},{"ATD",30},{"ATT",31},{"DFF",32},{"DFA",33},{"DFD",34},{"DFT",35},{"DAF",36},{"DAA",37},{"DAD",38},{"DAT",39},{"DDF",40},{"DDA",41},{"DDD",42},{"DDT",43},{"DTF",44},{"DTA",45},{"DTD",46},{"DTT",47},{"TFF",48},{"TFA",49},{"TFD",50},{"TFT",51},{"TAF",52},{"TAA",53},{"TAD",54},{"TAT",55},{"TDF",56},{"TDA",57},{"TDD",58},{"TDT",59},{"TTF",60},{"TTA",61},{"TTD",62},{"TTT",63} };
const map<int, const char> decimalLetter{ {0,'Z'},{1,'Y'},{2,'X'},{3,'W'},{4,'V'},{5,'U'},{6,'T'},{7,'S'},{8,'R'},{9,'Q'},{10,'P'},{11,'O'},{12,'N'},{13,'M'},{14,'L'},{15,'K'},{16,'J'},{17,'I'},{18,'H'},{19,'G'},{20,'F'},{21,'E'},{22,'D'},{23,'C'},{24,'B'},{25,'A'},{26,'9'},{27,'8'},{28,'7'},{29,'6'},{30,'5'},{31,'4'},{32,'3'},{33,'2'},{34,'1'},{35,'0'} };
const map<const string, const string> priorityLetter{ {"00","N"},{"01","L"},{"10","H"},{"11","U"} };
const map<const string, const string> trackingLetter{ {"00","T"},{"01","F"},{"10","D"},{"11","N"} };
const GLF6Polynomial generatorPolynomial = { 1,57,5,45,3,57,28,48,9,60,2,33,40 };
const GLF6 galoisExp[127] = { 1,2,4,8,16,32,3,6,12,24,48,35,5,10,20,40,19,38,15,30,60,59,53,41,17,34,7,14,28,56,51,37,9,18,36,11,22,44,27,54,47,29,58,55,45,25,50,39,13,26,52,43,21,42,23,46,31,62,63,61,57,49,33,1,2,4,8,16,32,3,6,12,24,48,35,5,10,20,40,19,38,15,30,60,59,53,41,17,34,7,14,28,56,51,37,9,18,36,11,22,44,27,54,47,29,58,55,45,25,50,39,13,26,52,43,21,42,23,46,31,62,63,61,57,49,33,1 };
const GLF6 galoisLog[64] = { 0,63,1,6,2,12,7,26,3,32,13,35,8,48,27,18,4,24,33,16,14,52,36,54,9,45,49,38,28,41,19,56,5,62,25,11,34,31,17,47,15,23,53,51,37,44,55,40,10,61,46,30,50,22,39,43,29,60,42,21,20,59,57,58 };

string decimalToBinary(unsigned long long int N, size_t size) { // converter of decimal to binary
	return bitset<32>(N).to_string().substr(32 - size, size);
}

// ---------------------- GALOIS FIELDS  ----------------------
// using the Russian Peasant simple algorithms

int trueMod(int n, int divisor) {
	int result = n % divisor;

	if (result < 0) {
		result += divisor;

		return result;
	}
	return result;
}

GLF6 galoisAdd(GLF6 a, GLF6 b) { // addition in galois 2^6
	return static_cast<GLF6>(a ^ b);
}

GLF6 galoisMult(GLF6 x, GLF6 y) { // multiplication in galois 2^6
	if (x == 0 || y == 0) return 0;
	return (galoisExp[galoisLog[x] + galoisLog[y]]);
}

GLF6 galoisDiv(GLF6 x, GLF6 y) { // division in galois 2^6
	if (y == 0) { cerr << "cannot divide by 0" << endl; exit(65); }
	if (x == 0) return 0;
	return (galoisExp[trueMod((int)galoisLog[x] + 63 - (int)galoisLog[y], 63)]);
}

GLF6 galoisPow(GLF6 x, int power) { // pow in galois 2^6
	return (galoisExp[(GLF6)trueMod((int)galoisLog[x] * power, 63)]);
}

GLF6 galoisInverse(GLF6 x) { // inverse in galois 2^6
	return (galoisExp[63 - galoisLog[x]]);
}

// if further debug needed use this function
void galoisPrint(GLF6 a) { // print number in galois 2^6
	int i = 8;
	while (i--) cout << ((a >> i & 1) + '0');
	cout << endl;
}

// ---------------------- POLYNOMIAL ALGORITHMS  -------------------
// The logarithm table approach will once again simplify and speed up our calculations when computing the power and the inverse
GLF6Polynomial galoisPolyScale(const GLF6Polynomial& p, const GLF6 x) {
	size_t pSize = p.size();
	GLF6Polynomial r(pSize, 0);

	for (size_t i = 0; i < pSize; i++) r[i] = galoisMult(p[i], x);

	return r;
}

// This function "adds" two polynomials (using exclusive-or, as usual)
GLF6Polynomial galoisPolyAdd(const GLF6Polynomial& p, const GLF6Polynomial& q) {
	size_t pSize = p.size();
	size_t qSize = q.size();
	size_t rSize = max(pSize, qSize);
	size_t rpDifference = rSize - pSize;
	size_t rqDifference = rSize - qSize;
	GLF6Polynomial r(rSize, 0);

	for (size_t i = 0; i < pSize; i++) r[i + rpDifference] = p[i];
	for (size_t i = 0; i < qSize; i++) r[i + rqDifference] ^= q[i];

	return r;
}

// This function multiplies two polynomials
GLF6Polynomial galoisPolyMult(const GLF6Polynomial& p, const GLF6Polynomial& q) {
	size_t pSize = p.size();
	size_t qSize = q.size();
	GLF6Polynomial r(pSize + qSize - 1, 0);

	for (size_t j = 0; j < qSize; j++) {
		for (size_t i = 0; i < pSize; i++) {
			r[i + j] ^= galoisMult(p[i], q[j]); // r[i + j] = galoisAdd(r[i + j], galoisMult(p[i], q[j]))
		}
	}

	return r;
}

// We need a function to evaluate a polynomial at a particular value of x, producing a scalar result. 
// Horner's method is used to avoid explicitly calculating powers of x. 
// Horner's method works by factorizing consecutively the terms, so that we always deal with x^1, iteratively, avoiding the computation of higher degree terms
GLF6 galoisPolyEval(const GLF6Polynomial& poly, const GLF6 x) {
	//Evaluates a polynomial in GF(2^p) given the value for x.
	GLF6 y = poly[0];

	for (size_t i = 1; i < poly.size(); i++) {
		y = static_cast<GLF6>(galoisMult(y, x) ^ poly[i]);
	}

	return y;
}

// Here is a function that implements extended synthetic division of GF(2^p) polynomials (extended because the divisor is a polynomial instead of a monomial)
pair<GLF6Polynomial, GLF6Polynomial> galoisPolyDiv(const GLF6Polynomial& dividend, const GLF6Polynomial& divisor) {
	GLF6Polynomial result(dividend);

	for (size_t i = 0; i < (dividend.size() - (divisor.size() - 1)); i++) {
		GLF6 coef = result[i];

		if (coef != 0) {
			for (size_t j = 1; j < divisor.size(); j++) {
				if (divisor[j] != 0)
					result[i + j] ^= static_cast<GLF6>(galoisMult(divisor[j], coef));
			}
		}
	}

	size_t separator = result.size() - static_cast<size_t>(((divisor.size()) - 1));
	GLF6Polynomial quotient = { result.begin(), result.begin() + separator };
	GLF6Polynomial remainder = { result.begin() + separator, result.end() };

	return make_pair(quotient, remainder); // return result[:separator], result[separator:] (quotient, remainder)
}

// ---------------------- PRE-CALCULATED TABLES CREATION --------------
// used to create the log and alog tables
// here for demonstation
void createTables() {
	GLF6 galoisExp[127];
	GLF6 galoisLog[64];
	GLF6 primitive = 67, x = 1;
	galoisLog[0] = 0;

	for (GLF6 i = 0; i < field; i++) {
		galoisExp[i] = x;
		galoisLog[x] = i;

		x <<= 1;
		if (x & field)
			x ^= primitive;
	}

	for (int i = field - 1; i < (field * 2) - 1; i++) galoisExp[i] = galoisExp[i - 63];

	cout << "{";
	for (int i = 0; i < 127; i++) {
		cout << (int)galoisExp[i];
		if (i != 127) cout << ",";
	}
	cout << "}" << endl;
	cout << "{";
	for (int i = 0; i < 64; i++) {
		cout << (int)galoisLog[i];
		if (i != 63) cout << ",";
	}
	cout << "}" << endl;
}

// create the generator polynomial.
// here for demonstation
void createPoly() {
	GLF6 nroots = 12;          //number of roots = no of ECC codewords
	GLF6Polynomial g(nroots + 1, 0);        //create polynomial coefficients - 1 more than number of roots
	g[0] = 1;                 //initialise the first one to 1

	GLF6 root = galoisExp[(initpwr * galoisLog[alpha]) % field];    // 1st is alpha**fcr // the same as galoisPow(alpha, initpwr)

	for (GLF6 i = 0; i < nroots; i++) {                            //nroot iterations needed
		//first do coefficients $nroots down to 1
		for (GLF6 j = nroots; j > 0; j--) { g[j] = galoisAdd(g[j - 1], galoisMult(g[j], root)); }
		g[0] = galoisMult(g[0], root);                    //end with coefficient of x**0

		root = galoisMult(root, alpha);            //mutiply by alpha to generate next root

		/*
		The same as:
		g = galoisPolyMul(g, {1, galoisPow(alpha, i + initpwr)});
		*/
	}
	cout << endl << "{";
	for (int r = nroots; r >= 0; r--) {
		cout << (static_cast<int>(g[r]) & 0xFF) << ',';
	}
	cout << "}";
}


// ---------------------- REED-SOLOMON DECODING -------------------
// encode a message to get its RS code
// only used for testing purposes
GLF6Polynomial rsEncode(GLF6Polynomial& message) {
	for (size_t i = 0; i < generatorPolynomial.size() - 1; i++) {
		message.push_back(0);
	}
	GLF6Polynomial remainder = galoisPolyDiv(message, generatorPolynomial).second;

	return remainder;
}

// Compute the syndromes polynomial, what characters are in error using Berlekamp-Massey
GLF6Polynomial rsCalcSyndromes(const GLF6Polynomial& msg, size_t nSym) {
	GLF6Polynomial synd(nSym, 0);

	for (size_t i = 0; i < nSym; i++) synd[i] = galoisPolyEval(msg, galoisPow(alpha, i + initpwr));
	synd.insert(synd.begin(), 0);

	return (synd); // pad with one 0 for mathematical precision (else we can end up with weird calculations sometimes)
}

// check if RS code gives nonzero syndromes
bool rsCheck(const GLF6Polynomial& syndrome) {
	/*Returns true if the message + ecc has no error of false otherwise (may not always catch a wrong decoding or a wrong message,
	particularly if there are too many errors, but it usually does)*/
	for (size_t j = 0; j < syndrome.size(); j++) {
		if (syndrome[j] != 0) return false;
	}

	return (true);
}

// Calculate the error locator polynomial from the !erasures! positions
GLF6Polynomial rsFindErrataLocator(const GLF6Polynomial& errataPositions) {
	GLF6Polynomial errataLocator = { 1 };
	GLF6Polynomial x0 = { 1 };
	GLF6Polynomial roots = { 0, 0 };

	for (auto position = errataPositions.begin(); position != errataPositions.end(); position++) {
		roots[0] = galoisPow(alpha, (*position));

		errataLocator = galoisPolyMult(errataLocator, galoisPolyAdd(x0, roots));
	}

	return errataLocator;
}

// Compute the errata evaluator polynomial
// from the syndrome and the errata locator polynomials.
GLF6Polynomial rsFindErrataEvaluator(const GLF6Polynomial& syndromes, const GLF6Polynomial& errataLocator, const size_t nSym) {
	GLF6Polynomial remainder = galoisPolyMult(syndromes, errataLocator);
	size_t remainderSize = remainder.size();
	size_t separator = remainderSize - (nSym + 1);

	remainder = { remainder.begin() + separator, remainder.end() };

	return remainder;
}

// -------------------- Error correction ----------
//Find error/errata locator and evaluator polynomials with Berlekamp-Massey algorithm
// if the erasure locator polynomial is supplied, we init with its value, so that we include erasures in the final locator polynomial
GLF6Polynomial rsFindErrorLocator(const GLF6Polynomial& syndromes, const size_t nSym, int eraseCount) {
	GLF6Polynomial errorLocator = { 1 }; // This is the main variable we want to fill, also called Sigma in other notations or more formally the errors/errata locator polynomial.
	GLF6Polynomial oldLocator = { 1 }; // BM is an iterative algorithm, and we need the errata locator polynomial of the previous iteration in order to update other necessary variables.

	short unsigned int syndShift = 0;
	if (syndromes.size() > nSym) syndShift = syndromes.size() - nSym;

	for (size_t i = 0; i < nSym - eraseCount; i++) { // generally: nsym-erase_count == len(synd), except when you input a partial erase_loc and using the full syndrome instead of the Forney syndrome, in which case nsym-erase_count is more correct (len(synd) will fail badly with IndexError).
		// if erasures locator is not provided, then either there's no erasures to account or we use the Forney syndromes, so we don't need to use erase_count nor erase_loc (the erasures have been trimmed out of the Forney syndromes).
		size_t K = i + syndShift;
		GLF6 delta = syndromes[K];

		for (size_t j = 1; j < errorLocator.size(); j++) {
			delta ^= galoisMult(errorLocator[errorLocator.size()-(j + 1)], syndromes[K - j]);
		}
		// delta is also called discrepancy. Here we do a partial polynomial multiplication (ie, we compute the polynomial multiplication only for the term of degree K). Should be equivalent to brownanrs.polynomial.mul_at().

		// Shift polynomials to compute the next degree
		oldLocator.push_back(0);

		// Iteratively estimate the errata locator and evaluator polynomials
		if (delta != 0) {
			if (oldLocator.size() > errorLocator.size()) {
				GLF6Polynomial newLocator = galoisPolyScale(oldLocator, delta);
				oldLocator = galoisPolyScale(errorLocator, galoisInverse(delta)); // delta
				errorLocator = newLocator;
			}

			errorLocator = galoisPolyAdd(errorLocator, galoisPolyScale(oldLocator, delta));
		}
	}

	while (errorLocator.size() && errorLocator[0] == 0) {
		errorLocator.erase(errorLocator.begin());
	}

	size_t errSize = errorLocator.size() - 1;
	if ((errSize) * 2 > nSym) {
		cerr << ("Too many errors to correct"); exit(64);
	}

	return errorLocator;
}
// using the error locator polynomial, we simply use a brute-force approach called trial substitution to find the zeros of this polynomial, which identifies the error locations 
GLF6Polynomial rsFindErrors(const GLF6Polynomial &errorLocator, const size_t messageSize) { // nmess is len(msg_in)
	//Find the roots (ie, where evaluation = zero) of error polynomial by brute-force trial, this is a sort of Chien's search
	//(but less efficient, Chien's search is a way to evaluate the polynomial such that each evaluation only takes constant time).'''
	size_t errSize = errorLocator.size() - 1;
	GLF6Polynomial errorPositions;

	for (size_t i = 0; i < messageSize; i++) {
		if (galoisPolyEval(errorLocator, galoisPow(alpha, (int)i)) == 0) { // It's a 0? Bingo, it's a root of the error locator polynomial
			errorPositions.push_back(messageSize - 1 - (GLF6) i);
		}
	}
	
	if (errorPositions.size() != errSize) {
		// couldn't find error locations
		cerr << ("Too many errors to correct (or few) errors found by Chien Search for the errata locator polynomial!"); exit(64);
	}

	return errorPositions;
}

// Error and erasure correction, decode both erasures and errors at the same time, up to a limit (called the Singleton Bound) 
GLF6Polynomial rsForneySyndromes(const GLF6Polynomial &syndromes, const GLF6Polynomial & erasurePositions, const size_t messageSize) {
	GLF6Polynomial coefficientPositions;

	for (auto position = erasurePositions.begin(); position != erasurePositions.end(); position++) {
		coefficientPositions.push_back((GLF6) messageSize - 1 - (*position));
	}

	// never overflow
	GLF6Polynomial forneySyndromes{ syndromes.begin() + 1, syndromes.end() };

	for (size_t i = 0; i < coefficientPositions.size(); i++) {
		GLF6 x = galoisPow(alpha, coefficientPositions[i]);

		for (size_t j = 0; j < (forneySyndromes.size() - 1); j++) {
			forneySyndromes[j] = (GLF6) galoisMult(forneySyndromes[j], x) ^ forneySyndromes[j + 1];
		}
	}
	return forneySyndromes;
}

// Calculates the values to correct the message using the Forney algorithm
GLF6Polynomial rsCorrectErrata(GLF6Polynomial& message, GLF6Polynomial syndromes, const GLF6Polynomial& errataPositions) {
	size_t messageSize = message.size();

	// ------- Calculate the errata evaluator polynomial ---------
	// Convert the errorPositions to coefficient degrees.
	GLF6Polynomial coefficientPositions;

	for (auto position = errataPositions.begin(); position != errataPositions.end(); position++) {
		coefficientPositions.push_back(messageSize - 1 - (*position));
	}
	size_t coefficientSize = coefficientPositions.size();

	GLF6Polynomial errorLocator = rsFindErrataLocator(coefficientPositions);
	size_t errorLocatorSize = errorLocator.size();

	reverse(syndromes.begin(), syndromes.end());

	GLF6Polynomial errorEvaluator = rsFindErrataEvaluator(syndromes, errorLocator, errorLocatorSize - 1);

	// ------ Get the error location polynomial (the roots of the error locator polynomial) ----------------
	GLF6Polynomial errorLocation;
	for (size_t i = 0; i < coefficientSize; i++) {
		int rootPwr = (field - 1) - coefficientPositions[i];
		errorLocation.push_back(galoisPow(alpha, -rootPwr));
	}

	// --------- Forney Algorithm (computing magnitudes) --------------
	GLF6Polynomial errorMagnitude(messageSize, 0); // Stores the values that need to be corrected
	size_t errorLocationSize = errorLocation.size();
	GLF6 errorLocatorPrime;

	// Compute the formal derivative of the error locator polynomial.
	// the formal derivative of the errata locator is used as the denominator of the Forney Algorithm, which simply says that the ith error value is given by
	// errorEvaluator(errorLocationCoefInv)) / errorLocatorDerivative(errorLocationCoefInv))
	for (size_t i = 0; i < errorLocationSize; i++) {
		GLF6 errorLocationCoef = errorLocation[i];
		GLF6 errorLocationCoefInv = galoisInverse(errorLocationCoef);

		GLF6Polynomial errorLocatorPrimeAux;
		for (size_t j = 0; j < errorLocationSize; j++) {
			if (j != i) {
				errorLocatorPrimeAux.push_back(galoisAdd(1, galoisMult(errorLocationCoefInv, errorLocation[j])));
			}
		}

		errorLocatorPrime = 1;
		for (auto coefficient = errorLocatorPrimeAux.begin(); coefficient != errorLocatorPrimeAux.end(); coefficient++) {
			errorLocatorPrime = galoisMult(errorLocatorPrime, (*coefficient));
		}

		// Compute y (evaluation of the errata evaluator polynomial
		GLF6 y = galoisPolyEval(errorEvaluator, errorLocationCoefInv); // numerator of the Forney algorithm
		// y = galoisMult(galoisPow(errorLocationCoef, 1 - initpwr), y); --- same as y * 1 with initpwr = 1

		if (errorLocatorPrime == 0) {
			cerr << ("can't be zero"); exit(64);
		}

		// Calculate the magnitude
		GLF6 magnitude = galoisDiv(y, errorLocatorPrime); // The value to repair
		errorMagnitude[errataPositions[i]] = magnitude; // store the magnitude for this error
	}

	// ---- Applying the error correction ----------
	message = galoisPolyAdd(message, errorMagnitude);

	return message;
}

GLF6Polynomial rsCorrectMessage(const GLF6Polynomial& message, GLF6 nSym, const GLF6Polynomial& erasurePositions, GLF6Polynomial& syndromes) {
	GLF6Polynomial output(message);
	size_t messageSize = message.size();

	if (erasurePositions.size() > nSym) {
		cerr << "Too many erasures to correct"; exit(65);
	}

	GLF6Polynomial forneySyndromes = rsForneySyndromes(syndromes, erasurePositions, messageSize);
	GLF6Polynomial errorLocator = rsFindErrorLocator(forneySyndromes, nSym, erasurePositions.size());
	reverse(errorLocator.begin(), errorLocator.end());
	GLF6Polynomial errorPositions = rsFindErrors(errorLocator, messageSize);

	GLF6Polynomial errataPositions(erasurePositions);
	errataPositions.insert(errataPositions.end(), errorPositions.begin(), errorPositions.end());

	output = rsCorrectErrata(output, syndromes, errataPositions);

	syndromes = rsCalcSyndromes(output, nSym);
	if (!rsCheck(syndromes)) { cerr << ("could not correct"); exit(64); }

	return output;
}

// --------------------- EXTRACT CODE ----------------
// One of the most needed functions, grabs the portion of code and passes it through the dictionary
void barsToPolynomial(string barcode, size_t start, size_t exEnd, GLF6Polynomial& result) {
	for (size_t i = start; i < exEnd; i += 3) {
		result.push_back(barsDecimal.at(barcode.substr(i, 3)));
	}
}

string polynomialToBinary(const GLF6Polynomial& polynomial) {
	stringstream initialConstruction; // extraction of reedsolomon code
	if (debug) cout << "Code: " << endl;
	unsigned short idx = 0;
	string converted;

	for (auto coef = polynomial.begin(); coef != polynomial.end(); coef++) {
		converted = decimalToBinary((*coef), 6);
		if (debug) cout << converted << " -<>- " << (int)(*coef) << endl;

		initialConstruction << converted;
	}
	if (debug) cout << endl;

	return initialConstruction.str();
}

// ---------------------- MAIN BEGIN ----------------------
// starts the whole magic regarding treating the code and making it feel at home
int main(int argc, char* argv[]) {
	if (argc < 2) {
		cerr << "Barcode string was not given, exiting...";
		exit(64); //  EX_USAGE. The command was used incorrectly, e.g., with the wrong number of arguments
	}
	string barcode = argv[1]; // grab the output of the barcodeReadingAPI
	if (barcode.length() != 75) {
		cerr << "size error" << endl; // checks for size
		exit(65); //  EX_DATAERR. The input data was incorrect in some way. 
	}
	if (debug) cout << "Debug is Enabled." << endl << "DEBUG BEGIN:" << endl;

	clock_t tStart = clock(); // time that the whole process takes to complete, only outputs when in debug
	stringstream output; // string stream that receives the final code

	// ---------------------- REED SOLOMON ----------------------
	// get reed solomon code example 
	//if (debug) cout << getCode(barcode.substr(30, 36), 33) << endl;
	GLF6Polynomial message;
	barsToPolynomial(barcode, 0, 30, message);
	barsToPolynomial(barcode, 66, 75, message);
	barsToPolynomial(barcode, 30, 66, message);

	GLF6Polynomial syndromes = rsCalcSyndromes(message, 12);
	if (!rsCheck(syndromes)) {
		if (debug) cout << "Errors Found, attempting to fix--------" << endl;

		message = rsCorrectMessage(message, 12, GLF6Polynomial{  }, syndromes); // the polynomial is where the errors are, adjust according to error positions
	}
	else {
		if (debug) cout << "No errors found" << endl;
	}

	// remove left and right sync and reed-solomon code
	// --- LeftSync e RightSync | leftsync 22 in binary | rightsync 38 binary
	message.erase(message.begin() + 13, message.end());
	message.erase(message.begin() + 10);
	message.erase(message.begin() + 2);

	string binaryCode = polynomialToBinary(message);
	if (debug) cout << "Full Code (w/o left/right sync and reed solomon): " << binaryCode << endl;

	// starts the construction of the final code
	// ---------------------- GET FORMAT CODE ----------------------
	const string formatCode = binaryCode.substr(0, 4);
	if (formatCode == "0010") output << "J18C";
	else {
		cerr << "[Prefix Unknown]" << endl;
		exit(65);
	}

	// ---------------------- GET COUNTRY CODE ----------------------
	const string countryCodeBinary = binaryCode.substr(4, 16);
	int countryDecimalValue = stoi(countryCodeBinary, nullptr, 2);
	char countryCode[4];

	for (int ch = 2; ch >= 0; ch--) {
		countryCode[ch] = decimalLetter.at(countryDecimalValue % 40);
		countryDecimalValue /= 40;
	}
	countryCode[3] = '\0';
	output << countryCode;

	// ---------------------- GET EQUIPMENT IDENTIFIER ----------------------
	const string hexCode = binaryCode.substr(20, 12);
	stringstream tempStream;
	// converts binary to hexadecimal (then turns all uppercase)
	tempStream << hex << stoi(hexCode, nullptr, 2);
	const string equipmentIdentifier = tempStream.str();

	for (string::size_type i = 0; i < equipmentIdentifier.length(); ++i) output << (char)toupper(equipmentIdentifier[i]);

	// ---------------------- GET ITEM PRIORITY ----------------------
	const string itemPriority = binaryCode.substr(32, 2);
	output << priorityLetter.at(itemPriority);

	// ---------------------- GET SERIAL CODES ----------------------
	string serialLeft = binaryCode.substr(34, 20);
	const string serialRight = binaryCode.substr(56, 10);
	const string serial = serialLeft.append(serialRight);
	if (debug) cout << "Serial: " << serial << endl;

	int serialDecimal = stoi(serial, nullptr, 2);
	if (debug) cout << "Serial (int): " << serialDecimal << endl;
	int auxNumber = serialDecimal / 16384;
	int itemNumber = serialDecimal % 16384;

	int month = (auxNumber / 5120) + 1; // month 
	auxNumber %= 5120;

	int day = auxNumber / 160; // day
	auxNumber %= 160;

	int hour = auxNumber / 6; // hour
	int minute = auxNumber % 6; // minute

	output << setw(2) << setfill('0') << month; // insert month
	output << setw(2) << setfill('0') << day; // insert day
	output << setw(2) << setfill('0') << hour; // insert hour
	output << minute; // insert minute
	output << setw(5) << setfill('0') << itemNumber; // insert item number

	// ---------------------- GET TRACKING INDICATOR ----------------------
	const string trackingIndicator = binaryCode.substr(54, 2);
	output << trackingLetter.at(trackingIndicator);

	// the completion of the decoded code, ready for output
	string finalOutput = output.str();
	if (debug) cout << endl << "Final String: ";
	cout << finalOutput << endl;
	if (debug) printf("\nDone! In: %.4fs\n", (float)(clock() - tStart) / CLOCKS_PER_SEC);

	return 0;
}