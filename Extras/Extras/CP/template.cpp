#include <bits/stdc++.h>
using namespace std;

#define ld long double
#define int long long
#define ull unsigned long long
#define vt vector
#define ar array
#define endl "\n"
#define fi first
#define se second
#define pb push_back
#define pbb pop_back
#define mp make_pair

#define mod 1000000007
#define MAX 1000001
#define PI 3.1415926535897932384626433832795
const ld EPS = 10e-9; // 10^-8
const int INF = 1000000009;
const int d4i[4] = {-1, 0, 1, 0}, d4j[4] = {0, 1, 0, -1};
const int d8i[8] = {-1, -1, 0, 1, 1, 1, 0, -1},
          d8j[8] = {0, 1, 1, 1, 0, -1, -1, -1};

#define p(x) printf("%lld\n", x);
#define pf(x) printf("%f\n", x);
#define s(x) scanf("%lld", &x);
#define sf(x) scanf("%lf", &x);
#define c(x) cout << x << "\n";
#define ctwo(x, y) cout << x << " " << y << "\n";
#define cthree(x, y, z) cout << x << " " << y << " " << z << "\n";
#define EACH(x, a) for (auto &x : a)
#define REP(a, b) for (int i = a; i < b; i++)
#define FOR(n) for (int i = 0; i < n; i++)
#define REPD(a, b) for (int i = a; i >= b; i--)
#define FORD(n) for (int i = n - 1; i >= 0; i--)
#define w(x)                                                                   \
  int x;                                                                       \
  cin >> x;                                                                    \
  while (x--)

#define mk(arr, n, type) type *arr = new type[n];
#define vi vector<int>
#define mii map<int, int>
#define sz(x) (int)x.size()
#define all(c) (c).begin(), (c).end()
#define rall(c) c.end(), c.begin()
#define pii pair<int, int>
#define MEM(a, b) memset(a, (b), sizeof(a));
#define pqb priority_queue<int>
#define pqs priority_queue<int, vi, greater<int>>
#define setbits(x) __builtin_popcountll(x)
#define zrobits(x) __builtin_ctzll(x)
#define ps(x, y) fixed << setprecision(y) << x;

#define vin(v, n)                                                              \
  for (int i = 0; i < n; i++) {                                                \
    cin >> v[i];                                                               \
  }
#define vprint(v)                                                              \
  for (auto i : v) {                                                           \
    cout << i << " ";                                                          \
  }                                                                            \
  cout << "\n";
#define ain(v, n)                                                              \
  for (int i = 0; i < n; i++) {                                                \
    cin >> v[i];                                                               \
  }
#define aprint(v, n)                                                           \
  for (int i = 0; i < n; i++) {                                                \
    cout << v[i] << " ";                                                       \
  }                                                                            \
  cout << "\n";
#define tr(it, a) for (auto it = a.begin(); it != a.end(); it++)
//#define 			gcd(a,b) __gcd(a, b);

#define SHUF(v) shuffle(all(v), rng);

#ifndef ONLINE_JUDGE
#define debug(x)                                                               \
  cerr << #x << " ";                                                           \
  _print(x);                                                                   \
  cerr << endl;
#else
#define debug(x)
#endif

#ifndef ONLINE_JUDGE
#define time()                                                                 \
  cerr << "Time taken : "                                                      \
       << ((long double)duration.count()) / ((long double)1e9) << "s "         \
       << endl;
#else
#define time()
#endif

void _print(int t) { cerr << t; }
void _print(string t) { cerr << t; }
void _print(char t) { cerr << t; }
void _print(ld t) { cerr << t; }
void _print(double t) { cerr << t; }
void _print(ull t) { cerr << t; }

template <class T, class V> void _print(pair<T, V> p);
template <class T> void _print(vector<T> v);
template <class T> void _print(set<T> v);
template <class T, class V> void _print(map<T, V> v);
template <class T> void _print(multiset<T> v);
template <class T, class V> void _print(pair<T, V> p) {
  cerr << "{";
  _print(p.ff);
  cerr << ",";
  _print(p.ss);
  cerr << "}";
}
template <class T> void _print(vector<T> v) {
  cerr << "[ ";
  for (T i : v) {
    _print(i);
    cerr << " ";
  }
  cerr << "]";
}
template <class T> void _print(set<T> v) {
  cerr << "[ ";
  for (T i : v) {
    _print(i);
    cerr << " ";
  }
  cerr << "]";
}
template <class T> void _print(multiset<T> v) {
  cerr << "[ ";
  for (T i : v) {
    _print(i);
    cerr << " ";
  }
  cerr << "]";
}
template <class T, class V> void _print(map<T, V> v) {
  cerr << "[ ";
  for (auto i : v) {
    _print(i);
    cerr << " ";
  }
  cerr << "]";
}

template <typename T> bool chkmin(T &a, T b) { return (b < a) ? a = b, 1 : 0; }
template <typename T> bool chkmax(T &a, T b) { return (b > a) ? a = b, 1 : 0; }

template <class A> void read(vt<A> &v);
template <class A, size_t S> void read(ar<A, S> &a);
template <class T> void read(T &x) { cin >> x; }
void read(double &d) {
  string t;
  read(t);
  d = stod(t);
}
void read(long double &d) {
  string t;
  read(t);
  d = stold(t);
}
template <class H, class... T> void read(H &h, T &...t) {
  read(h);
  read(t...);
}
template <class A> void read(vt<A> &x) {
  EACH(a, x)
  read(a);
}
template <class A, size_t S> void read(array<A, S> &x) {
  EACH(a, x)
  read(a);
}

string to_string(char c) { return string(1, c); }
string to_string(bool b) { return b ? "true" : "false"; }
string to_string(const char *s) { return string(s); }
string to_string(string s) { return s; }
string to_string(vt<bool> v) {
  string res;
  FOR(sz(v))
  res += char('0' + v[i]);
  return res;
}

template <typename... Args> void write(Args &&...args) {
  (std::cout << ... << args) << " ";
}

void fast_IO() {
  ios_base::sync_with_stdio(0);
  cin.tie(0);
  cout.tie(0);
  // #ifndef ONLINE_JUDGE
  // 	freopen("debug.txt", "w", stderr);
  // #endif
}

int gcd(int a, int b) {
  if (!a || !b)
    return a | b;
  unsigned shift = __builtin_ctz(a | b);
  a >>= __builtin_ctz(a);
  do {
    b >>= __builtin_ctz(b);
    if (a > b)
      swap(a, b);
    b -= a;
  } while (b);
  return a << shift;
}

int lcm(int a, int b) { return a / gcd(a, b) * b; }

int power(int a, int b) {
  int res = 1;
  while (b > 0) {
    if (b & 1)
      res = res * a;
    a = a * a;
    b >>= 1;
  }
  return res;
}

int gcd_equation(int a, int b, int &x, int &y) {
  if (b == 0) {
    x = 1;
    y = 0;
    return a;
  }
  int x1, y1;
  int d = gcd_equation(b, a % b, x1, y1);
  x = y1;
  y = x1 - y1 * (a / b);
  return d;
}

//////////////////////////////////////////////////////////////////////////////
////////////  					TEMPLATE ENDS
///////////////
//////////////////////////////////////////////////////////////////////////////

void solve() {

}

int32_t main() {
  fast_IO();
  cerr << fixed << setprecision(10);
  auto start = std::chrono::high_resolution_clock::now();
  int t = 1;
  // cin >> t;
  // for (int i = 1; i <= t; ++i) {
  //  cout << "Case #" << i << ": ";
  // 	solve();
  // }
  while (t--) {
    solve();
  }
  auto stop = std::chrono::high_resolution_clock::now();
  auto duration =
      std::chrono::duration_cast<std::chrono::nanoseconds>(stop - start);
  // time()
  return 0;
}
