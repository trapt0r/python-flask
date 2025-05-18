package com.example;

import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.*;

public class AppTest {
    @Test
    public void testMocking() {
        Runnable r = mock(Runnable.class);
        r.run();
        verify(r).run();
    }
}
