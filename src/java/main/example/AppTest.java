package com.example;

import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.*;

public class AppTest {

    @Test
    void stressMockito() throws Exception {
        for (int i = 0; i < 1000; i++) {
            Runnable r = mock(Runnable.class);
            r.run();
            verify(r).run();
        }
        Thread.sleep(500); // simulate processing delay
    }
}
