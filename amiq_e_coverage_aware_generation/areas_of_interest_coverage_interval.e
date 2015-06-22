<'
extend sys {
    data : uint;
    keep data <= 10000;
    keep soft data == select { 
        50 : normal(0,     10000*0.001);
        50 : normal(10000, 10000*0.001);
    };
    event data_cvr_e;
    cover data_cvr_e is {
        item data using ranges = {
            range ([0..9],        "", 1);
            range ([10..9990]);
            range ([9991..10000], "", 1);
        };
    };
    run() is also {
        for i from 1 to 100 {
            gen data;
            emit data_cvr_e;
        };
    };
};
'>