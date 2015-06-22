<'
data : uint (bits : 12);
keep soft data == select {
    100 : normal(0, ipow(2, 12)*0.15);
};
'>