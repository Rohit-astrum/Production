/*
 * Unit tests for RateOfReturnUtility class.
 *
 */
@isTest(seeAllData = false)
public with sharing class RateOfReturnUtilityTest {
    @IsTest
    static void positiveTest1() {
        RateOfReturnUtility irr = new RateOfReturnUtility();
        // Capital Calls:
        irr.addCashflow(Date.newInstance(2003, 09, 15), -460000);
        irr.addCashflow(Date.newInstance(2004, 05, 18), -552000);
        irr.addCashflow(Date.newInstance(2004, 09, 20), -506000);
        irr.addCashflow(Date.newInstance(2005, 01, 17), -276000);
        irr.addCashflow(Date.newInstance(2005, 04, 1), -414000);
        irr.addCashflow(Date.newInstance(2005, 09, 7), -690000);
        irr.addCashflow(Date.newInstance(2005, 10, 15), -313425);
        irr.addCashflow(Date.newInstance(2006, 07, 10), -690000);
        irr.addCashflow(Date.newInstance(2007, 03, 1), -698575);

        // Distributions:
        irr.addCashflow(Date.newInstance(2005, 10, 15), 313425);
        irr.addCashflow(Date.newInstance(2008, 4, 24), 1533331);
        irr.addCashflow(Date.newInstance(2009, 3 ,5), 230000);
        irr.addCashflow(Date.newInstance(2009, 12, 1), 184000); 
        irr.addCashflow(Date.newInstance(2012, 6, 30), 9710000); 

        Decimal result = irr.calculate(0.15);
        System.assertEquals(0.1734, result.setScale(4));
    }

    @IsTest
    static void positiveTest2() {
        RateOfReturnUtility irr = new RateOfReturnUtility();

        irr.addCashflow(Date.newInstance(2010, 12, 1), -350000);
        irr.addCashflow(Date.newInstance(2011, 2, 1), -80000);
        irr.addCashflow(Date.newInstance(2011, 3, 1), -350000);
        irr.addCashflow(Date.newInstance(2011, 4, 1), -90000);
        irr.addCashflow(Date.newInstance(2011, 5, 1), -10000);
        irr.addCashflow(Date.newInstance(2011, 6, 1), -110000);
        irr.addCashflow(Date.newInstance(2011, 7, 1), -200000);
        irr.addCashflow(Date.newInstance(2011, 8, 1), -1435000);
        irr.addCashflow(Date.newInstance(2011, 9, 1), -200500);
        irr.addCashflow(Date.newInstance(2012, 1, 1), -1424975);
        irr.addCashflow(Date.newInstance(2012, 2, 1), -110000);
        irr.addCashflow(Date.newInstance(2012, 3, 25), -583091);
        irr.addCashflow(Date.newInstance(2012, 4, 16), -1382000);
        irr.addCashflow(Date.newInstance(2012, 4, 16), 672882);
        irr.addCashflow(Date.newInstance(2012, 5, 1), -257525);
        irr.addCashflow(Date.newInstance(2012, 6, 1), -125000);
        irr.addCashflow(Date.newInstance(2012, 10, 1), -5389875);
        irr.addCashflow(Date.newInstance(2012, 12, 30), 11725424);

        Decimal result = irr.calculate(0.15);
        //System.assertEquals(0.1885, result.setScale(4));
        System.assertEquals(0.0352, result.setScale(4)); // 3/28 - updated expected value to match result from RateOfReturnUtility function in Excel spreadsheet
    }

    @IsTest
    static void positiveTest3() {
        RateOfReturnUtility irr = new RateOfReturnUtility();

        irr.addCashflow(Date.newInstance(2008, 1, 1), -10000);
        irr.addCashflow(Date.newInstance(2008, 3, 1), 2750);
        irr.addCashflow(Date.newInstance(2008, 10, 30), 4250);
        irr.addCashflow(Date.newInstance(2009, 2, 15), 3250);
        irr.addCashflow(Date.newInstance(2009, 4, 1), 2750);

        Decimal result = irr.calculate(0.15);
        System.assertEquals(0.3734, result.setScale(4));
    }

    /**
     * Test case where result is negative.
     * NOTE: currently not supported, as will try a guess of less than -1.0 
     */
    @isTest static void positiveTest4() {
        RateOfReturnUtility irr = new RateOfReturnUtility();

        irr.addCashflow(Date.newInstance(2012, 08, 13), -2000000);
        irr.addCashflow(Date.newInstance(2012, 10, 24), -2000000);
        irr.addCashflow(Date.newInstance(2013, 01, 21), -2000000);
        irr.addCashflow(Date.newInstance(2013, 03, 31), 2540000);

        // System.assertEquals(-0.9, result.setScale(2), 'Incorrect IRR value'); <-- TODO: handle this in future
        try {
            Decimal result = irr.calculate(0.15);
        } catch(RateOfReturnUtility.IRRException e) {
            String exceptionMsg = e.getMessage();
            System.assertEquals('Unable to find solution (next guess cannot be less than -1.0)', exceptionMsg, 'Incorrect error message');
        }
    }

    /**
     * Test case where there are no positive cashflows.
     */
    @isTest static void negativeTest1() {
        RateOfReturnUtility irr = new RateOfReturnUtility();

        irr.addCashflow(Date.newInstance(2012, 08, 12), -10000);
        irr.addCashflow(Date.newInstance(2012, 10, 12), -10000);
        irr.addCashflow(Date.newInstance(2013, 01, 13), -10000);

        try {
            Decimal result = irr.calculate(0.15);
        } catch(RateOfReturnUtility.IRRException e) {
            String exceptionMsg = e.getMessage();
            System.assertEquals('At least one positive cash flow and one negative cash flow are required', exceptionMsg, 'Incorrect error message');
        }
    }
}