// $Id: hash_unit.mqh 118 2014-02-28 23:50:37Z ydrol $
// Hash Unit test functions - replace Print(), with  Alert() or your own error logging.
// Copyright (C) 2014, Andrew Lord (NICKNAME=lordy) <forex@NICKNAME.org.uk> 

#ifndef YDROL_HASH_UNIT_MQH
#define YDROL_HASH_UNIT_MQH

void testHash() {

#define HASH_TEST_SIZE 1000

    // Force hash collisions using a small hash size.
    Hash *h = new Hash(5,true);

    int count = 0;
    HashLoop *l ;

    for(int i = 0 ; i < HASH_TEST_SIZE ; i++ ) {
        h.hPutInt((string)i,i);
    }
    // Read and verify
    for(int i = 0 ; i < HASH_TEST_SIZE ; i++ ) {
        int j = h.hGetInt((string)i);
        if (i != j) Print("Hash fail1",(string)i,(string)j);
    }
    count = 0;

    int a[HASH_TEST_SIZE];

    ArrayInitialize(a,0);
    // Test the loop
    for( l = new HashLoop(h) ; l.hasNext() ; l.next()) {
        count++;

        //Check loop key values match
        int i = (int)StringToInteger(l.key());
        int j = l.valInt();
        if (i != j) Print("Hash fail2",(string)i,(string)j);

        // Check occurences
        a[i]++;
        if (a[i] != 1) Print("Hash fail3",(string)i,(string)j);
    }
    delete l;

    // Check total
    if (count != HASH_TEST_SIZE) Print("Hash fail4 ",(string)count);

    // Check distribution
    for(int i = 0 ; i < HASH_TEST_SIZE ; i++ ) {
        h.hPutInt("XXXXXXXXXXX"+(string)i+"YYYYYYYYYYYY",i);
    }

    delete h;
}
#endif
