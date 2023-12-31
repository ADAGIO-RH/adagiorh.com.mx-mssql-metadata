USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-18
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE  proc [Transporte].[spIRutaProgramada](
        
        @IDRuta int null	 		
        ,@FechaInicio DATE        
        ,@FechaFin DATE        
        ,@IDUsuario int null	 		
        ,@Afectar int =0
	)
AS  
BEGIN  

        Declare @val Varchar(max),@msgError varchar(max); 
    DECLARE @OldJSON Varchar(Max),
	    @NewJSON Varchar(Max)        

    declare @tempResponse as table (
                    [KMRuta] int,
                    [IDRutaPersonal] INT ,
                    [IDRuta] int,                
                    [IDEmpleado] int ,
                    [ClaveEmpleado]    varchar(20),
                    [Nombres]    varchar(100),
                    [Apellidos]    varchar(100),
                    [FechaInicio]  date,
                    [FechaFin]  date,                    
                    [Fecha]       date,
                    [TipoHorario] int,     
                    [IDHorario] int,     
                    [IDRutaHorario] int,     
                    [HoraSalida] time     , 
                    [HoraLlegada] time    ,
                    [IDRutaProgramada]   int ,
                    [Existe]   int 
                    
                    
    ); 
    declare @tempIDSRutaProgramada as table (
        [IDRutaProgramadaTemp] int,
        [IDRutaProgramada] int
    )
  
    
    /*IF (exists(SELECT * FROM Transporte.tblRutasProgramadas s where s.Fecha between @FechaInicio and @FechaFin  and s.IDRuta=@IDRuta ) and @Afectar=1)
    begin     
        
        Select @val = COALESCE(@val + ', ' + CONVERT(varchar,  s.Fecha, 23) , CONVERT(varchar, s.Fecha, 23)) 
        From Transporte.tblRutasProgramadas s  where s.Fecha  between @FechaInicio and @FechaFin and s.IDRuta=@IDRuta
        group by Fecha

        select @msgError=concat('Esta ruta tiene programaciones asignada las fechas.(',@val,')')
        raiserror(@msgError,16,1);
		return;
    END
    
    else */
    begin    
        declare  @Fechas [App].[dtFechas]   
        insert @Fechas  
        exec app.spListaFechas @FechaIni =@FechaInicio, @FechaFin = @FechaFin
        
        insert into @tempResponse
        select 
        c.KMRuta,
        p.IDRutaPersonal,
        case when @IDRuta = p.IDRuta1 then  p.IDRuta1 else  p.IDRuta2 end   ,
        p.IDEmpleado,
        isnull(m.ClaveEmpleado,'EXTERNOS'),
        p.Nombres,
        p.Apellidos,
        p.FechaInicio,
        p.FechaFin,        
        f.Fecha,
        case when @IDRuta = p.IDRuta1 then 0 else 1 end   ,
        chd.IDHorario,  
        ch.IDRutaHorario,  
        ch.HoraSalida,
        ch.HoraLlegada,
        isnull(rp.IDRutaProgramada,0),
        case when rpp.IDRutaProgramadaPersonal is null then 0 else  1 end     
        from rh.tblEmpleadosMaster m
        inner join Transporte.tblRutasPersonal p on p.IDEmpleado=m.IDEmpleado and (p.IDRuta1=@IDRuta or p.IDRuta2=@IDRuta) and (@FechaInicio between  p.FechaInicio  and p.FechaFin)
        inner join @Fechas f on f.Fecha between p.FechaInicio and p.FechaFin
        inner join Asistencia.tblHorariosEmpleados h on h.IDEmpleado=m.IDEmpleado and h.Fecha=f.Fecha    
        inner join Transporte.tblCatRutas c on c.IDRuta=@IDRuta
        inner join Transporte.tblCatRutasHorarios ch on ch.IDRuta=c.IDRuta
        inner join Transporte.tblCatRutasHorariosDetalle chd on chd.IDHorario=h.IDHorario and chd.IDRutaHorario=ch.IDRutaHorario        
        left join Transporte.tblRutasProgramadas rp on rp.Fecha=f.Fecha and rp.HoraLlegada =ch.HoraLlegada and rp.HoraSalida=ch.HoraSalida and rp.IDRuta=@IDRuta
        left join Transporte.tblRutasProgramadasPersonal rpp on rpp.IDRutaPersonal=p.IDRutaPersonal and rp.IDRutaProgramada=rpp.IDRutaProgramada


        insert into @tempResponse
        select 
        c.KMRuta,
        p.IDRutaPersonal,
        case when @IDRuta = p.IDRuta1 then  p.IDRuta1 else  p.IDRuta2 end   ,
        p.IDEmpleado,
        'EXTERNOS',
        p.Nombres,
        p.Apellidos,
        p.FechaInicio,
        p.FechaFin,        
        f.Fecha,
        case when @IDRuta = p.IDRuta1 then 0 else 1 end   ,
        0,
        ch.IDRutaHorario,
        ch.HoraSalida,
        ch.HoraLlegada,
        0,
        0 
        from Transporte.tblRutasPersonal p 
        inner join @Fechas f on f.Fecha between p.FechaInicio and p.FechaFin
        inner join Transporte.tblCatRutas c on c.IDRuta=@IDRuta
        inner join Transporte.tblCatRutasHorarios ch on ch.IDRutaHorario= case when p.IDRuta1=@IDRuta then p.IDRutaHorario1 else p.IDRutaHorario2 end
        
        



        if @Afectar=1 
        begin 
        
                update   t set t.IDRutaProgramada= rp.IDRutaProgramada
                    from @tempResponse t 
                left join Transporte.tblRutasProgramadas rp on rp.Fecha=t.Fecha and rp.HoraLlegada =t.HoraLlegada and rp.HoraSalida=t.HoraSalida and rp.IDRuta=@IDRuta
                where t.Existe = 0 

                
 
                    DECLARE @archive TABLE (
                        ActionType VARCHAR(50),
                        IDRutaProgramada int,
                        IDRuta int,
                        HoraLlegada TIME,
                        HoraSalida time,
                        Fecha date,
                        IDRutaHorario int
                    );

                    
                    if object_id('tempdb..#TempRutasProgramadas') is not null drop table #TempRutasProgramadas;      

                    select t.IDRuta,t.Fecha,t.HoraLlegada,t.HoraSalida,cr.KMRuta,@IDUsuario [IDUsuario],IDRutaHorario 
                    into #TempRutasProgramadas
                    from @tempResponse t
                    inner join Transporte.tblCatRutas cr on cr.IDRuta= t.IDRuta                    
                    GROUP by t.Fecha,t.HoraLlegada,t.HoraSalida,cr.KMRuta,t.IDRuta,IDRutaHorario

                    MERGE Transporte.tblRutasProgramadas AS TARGET
                    USING #TempRutasProgramadas as SOURCE
                    on TARGET.Fecha = SOURCE.Fecha and  TARGET.IDRuta = SOURCE.IDRuta and   TARGET.IDRutaHorario = SOURCE.IDRutaHorario
                    WHEN MATCHED THEN
                        update 
                        set TARGET.HoraLlegada = SOURCE.HoraLlegada,
                            TARGET.HoraSalida = SOURCE.HoraSalida,
                            TARGET.KMRuta = SOURCE.KMRuta
                    WHEN NOT MATCHED BY TARGET THEN 
                        INSERT(IDRuta,HoraLlegada,HoraSalida,KMRuta,Fecha,IDUsuario,IDRutaHorario)
                        values(SOURCE.IDRuta,
                                SOURCE.HoraLlegada,
                                SOURCE.HoraSalida,
                                SOURCE.KMRuta,SOURCE.Fecha,@IDUsuario,SOURCE.IDRutaHorario)
                    WHEN NOT MATCHED BY SOURCE AND TARGET.IDRuta = @IDRuta  and TARGET.Fecha in(select Fecha from @Fechas  )  THEN 
                    DELETE
                        OUTPUT $action, 
                        
                        INSERTED.IDRutaProgramada AS IDRutaProgramada,                                
                        INSERTED.IDRuta AS IDRuta, 		
                        INSERTED.HoraLlegada AS HoraLlegada, 		
                        INSERTED.HoraSalida AS HoraSalida, 		                                
                        INSERTED.Fecha AS Fecha, 		
                        INSERTED.IDRutaHorario AS IDRutaHorario
                        into @archive;

                        
                
                    if object_id('tempdb..#TempRutasProgramadasPersonal') is not null drop table #TempRutasProgramadasPersonal;      

                    select s.IDRutaPersonal,a.IDRutaProgramada 
                    into #TempRutasProgramadasPersonal
                    from @tempResponse s 
                    inner join @archive a on s.Fecha =a.Fecha and s.IDRuta=a.IDRuta and a.IDRutaHorario=s.IDRutaHorario


                    MERGE Transporte.tblRutasProgramadasPersonal AS TARGET
                    USING #TempRutasProgramadasPersonal as SOURCE
                    on TARGET.IDRutaPersonal = SOURCE.IDRutaPersonal and  TARGET.IDRutaProgramada = SOURCE.IDRutaProgramada  
                    WHEN MATCHED THEN
                        update 
                        set TARGET.IDRutaPersonal = SOURCE.IDRutaPersonal,
                            TARGET.IDRutaProgramada = SOURCE.IDRutaProgramada                            
                    WHEN NOT MATCHED BY TARGET THEN 
                        INSERT(IDRutaPersonal,IDRutaProgramada)
                        values(SOURCE.IDRutaPersonal,
                                SOURCE.IDRutaProgramada)
                    WHEN NOT MATCHED BY SOURCE AND TARGET.IDRutaProgramada in (select DISTINCT IDRutaProgramada from #TempRutasProgramadasPersonal) THEN  
                    DELETE
                        --OUTPUT $action, 
                        
                        --INSERTED.IDRutaPersonal AS IDRutaPersonal,                                
                        --DELETED.IDRutaPersonal AS IDRutaPersonal
						;
                      

            /*
                insert into Transporte.tblRutasProgramadas (IDRuta,Fecha,HoraLlegada,HoraSalida,KMRuta,IDUsuario,IDRutaHorario)    
                select t.IDRuta,t.Fecha,t.HoraLlegada,t.HoraSalida,cr.KMRuta,@IDUsuario,IDRutaHorario from @tempResponse t
                inner join Transporte.tblCatRutas cr on cr.IDRuta= t.IDRuta
                where t.Existe = 0
                GROUP by t.Fecha,t.HoraLlegada,t.HoraSalida,cr.KMRuta,t.IDRuta,IDRutaHorario

                update   t set t.IDRutaProgramada= rp.IDRutaProgramada
                from @tempResponse t 
                left join Transporte.tblRutasProgramadas rp on rp.Fecha=t.Fecha and rp.HoraLlegada =t.HoraLlegada and rp.HoraSalida=t.HoraSalida and rp.IDRuta=@IDRuta
                where t.Existe = 0 
                
                insert into Transporte.tblRutasProgramadasPersonal (IDRutaPersonal,IDRutaProgramada)
                select t.IDRutaPersonal,IDRutaProgramada From  @tempResponse t             
                where t.Existe=0    
            */


        end 
        
        select t.*,
        cr.ClaveRuta ,
        cr.Descripcion,
        cr.Destino,
        cr.Origen,
        cr.KMRuta        
        from @tempResponse t
        inner join  Transporte.tblCatRutas cr on cr.IDRuta=t.IDRuta        
    end     
    
END
GO
