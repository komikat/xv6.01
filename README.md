
# Table of Contents

1.  [Spec 1](#orgb4e694c)
2.  [Spec 2](#org53f8a2b)
    1.  [FCFS](#org47b9bc6)



<a id="orgb4e694c"></a>

# Spec 1

-   `getreadcount()` passes on both tests.
-   works as a syscall using the shell.


<a id="org53f8a2b"></a>

# Spec 2


<a id="org47b9bc6"></a>

## FCFS

-   FCFS performance:
    Average rtime: 14
    wait: 129

-   MLFQ experiments
    `TOO_LONG`: waiting time after which process priority upgrades.
    
    <table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">
    
    
    <colgroup>
    <col  class="org-right" />
    
    <col  class="org-right" />
    
    <col  class="org-right" />
    </colgroup>
    <thead>
    <tr>
    <th scope="col" class="org-right">TOO<sub>LONG</sub></th>
    <th scope="col" class="org-right">average rtime</th>
    <th scope="col" class="org-right">wait</th>
    </tr>
    </thead>
    
    <tbody>
    <tr>
    <td class="org-right">30</td>
    <td class="org-right">26</td>
    <td class="org-right">170</td>
    </tr>
    
    
    <tr>
    <td class="org-right">10</td>
    <td class="org-right">14</td>
    <td class="org-right">135</td>
    </tr>
    
    
    <tr>
    <td class="org-right">13</td>
    <td class="org-right">14</td>
    <td class="org-right">135</td>
    </tr>
    
    
    <tr>
    <td class="org-right">20</td>
    <td class="org-right">14</td>
    <td class="org-right">134</td>
    </tr>
    
    
    <tr>
    <td class="org-right">5</td>
    <td class="org-right">14</td>
    <td class="org-right">142</td>
    </tr>
    
    
    <tr>
    <td class="org-right">8</td>
    <td class="org-right">15</td>
    <td class="org-right">144</td>
    </tr>
    
    
    <tr>
    <td class="org-right">30</td>
    <td class="org-right">15</td>
    <td class="org-right">137</td>
    </tr>
    </tbody>
    </table>

-   Graphs
    
    ![img](./../../graphs/9.png "8 ticks")
    
    ![img](./../../graphs/9.png "9 ticks")
    
    ![img](./../../graphs/10.png "10 ticks")
    
    ![img](./../../graphs/15.png "15 ticks")
    
    The code used to generate these graphs can be found in [graphs python notebook](graphs.ipynb).

