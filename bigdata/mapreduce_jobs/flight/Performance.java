package org.myorg;
//==============================================================================
public class Performance {
    String Year;
    String Month;
    String DayofMonth;
    String DayOfWeek;
    String DepTime;
    String CRSDepTime;
    String ArrTime;
    String CRSArrTime;
    String UniqueCarrier;
    String FlightNum;
    String TailNum;
    String ActualElapsedTime;
    String CRSElapsedTime;
    String AirTime;
    String ArrDelay;
    String DepDelay;
    String Origin;
    String Dest;
    String Distance;
    String TaxiIn;
    String TaxiOut;
    String Cancelled;
    String CancellationCode;
    String Diverted;
    String CarrierDelay;
    String WeatherDelay;
    String NASDelay;
    String SecurityDelay;
    String LateAircraftDelay;
//------------------------------------------------------------------------------
    public Performance(String[] info) {
        this.Year = info[0];
        this.Month = info[1];
        this.DayofMonth = info[2];
        this.DayOfWeek = info[3];
        this.DepTime = info[4];
        this.CRSDepTime = info[5];
        this.ArrTime = info[6];
        this.CRSArrTime = info[7];
        this.UniqueCarrier = info[8];
        this.FlightNum = info[9];
        this.TailNum = info[10];
        this.ActualElapsedTime = info[11];
        this.CRSElapsedTime = info[12];
        this.AirTime = info[13];
        this.ArrDelay = info[14];
        this.DepDelay = info[15];
        this.Origin = info[16];
        this.Dest = info[17];
        this.Distance = info[18];
        this.TaxiIn = info[19];
        this.TaxiOut = info[20];
        this.Cancelled = info[21];
        this.CancellationCode = info[22];
        this.Diverted = info[23];
        this.CarrierDelay = info[24];
        this.WeatherDelay = info[25];
        this.NASDelay = info[26];
        this.SecurityDelay = info[27];
        this.LateAircraftDelay = info[28];
    }
//------------------------------------------------------------------------------
}
//==============================================================================
