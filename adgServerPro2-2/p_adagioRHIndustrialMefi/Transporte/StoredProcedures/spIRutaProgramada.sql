USE [p_adagioRHIndustrialMefi]
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

    DECLARE  @Fechas [App].[dtFechas]   
    INSERT @Fechas  
    EXEC app.spListaFechas @FechaIni =@FechaInicio, @FechaFin = @FechaFin
        
    declare @tblProgramacionRutas as table ( 
                [IDRuta] int,   
                [IDRutaPersonal] INT ,
                [KMRuta] int,
                [HoraSalida] time     , 
                [HoraLlegada] time    ,
                [IDRutaProgramada]   int ,
                [IDRutaHorario] int,     
                [ClaveRuta] VARCHAR(20),
                [Descripcion] VARCHAR(150),
                [ConcatHorariosEmpleados] VARCHAR(max),
                [Destino] VARCHAR(150),
                [Origen] VARCHAR(150),
                [IDEmpleado] int ,
                [ClaveEmpleado]    varchar(20),
                [Nombres]    varchar(100),
                [Apellidos]    varchar(100),                    
                [FechaProgramada]       date,
                [IDHorarioEmpleado] int,                     
                [DescripcionHorarioEmpleado] varchar(100),                     
                [Vigente] bit,
                [TieneAusentismo] bit,
                [DescripcionAusentismo] varchar(100),
                [EncontroHorarioRuta] bit,
                [Asignado] bit
    ) 

    if object_id('tempdb..#tempDiasVigencias')	is not null drop table #tempDiasVigencias;  

    create table #tempDiasVigencias (
        IDEmpleado int
        ,Fecha date
        ,Vigente bit
    );
    
    insert into @tblProgramacionRutas ( [IDRuta],[IDRutaPersonal],[ClaveRuta],[Descripcion] ,[Destino],[Origen],[KMRuta], [IDEmpleado], [Nombres], [Apellidos], [FechaProgramada])
    SELECT  r.IDRuta , RP.IDRutaPersonal ,R.ClaveRuta,R.Descripcion,R.Descripcion,R.Origen,R.KMRuta, rp.IDEmpleado,rp.Nombres,rp.Apellidos,f.Fecha  
    From Transporte.tblRutasPersonal rp with(nolock)
        --inner join Transporte.tblCatRutas r on r.IDRuta = rp.IDRuta1  
        inner join Transporte.tblCatRutas r with(nolock) on r.IDRuta = @IDRuta and r.IDRuta in (rp.IDRuta1,rp.IDRuta2)           
        inner join @Fechas f on f.Fecha between rp.FechaInicio and rp.FechaFin 
    --where rp.IDRuta1=@IDRuta
    where (rp.IDRuta1=@IDRuta or rp.IDRuta2=@IDRuta)

    declare @dtEmpleados RH.dtEmpleados    
    insert @dtEmpleados(IDEmpleado) 
    select IDEmpleado from @tblProgramacionRutas

    insert #tempDiasVigencias
    exec RH.spBuscarListaFechasVigenciaEmpleado  
    @dtEmpleados = @dtEmpleados 
    ,@Fechas = @Fechas
    ,@IDUsuario = @IDUsuario 

    delete from @dtEmpleados;

        
    update e   set e.Vigente=c.Vigente
    from @tblProgramacionRutas e
    inner join #tempDiasVigencias c on c.IDEmpleado=e.IDEmpleado and c.Fecha=e.FechaProgramada
    
    delete from #tempDiasVigencias        


    update e   set e.ClaveEmpleado=isnull(c.ClaveEmpleado,'EXTERNO')
    from @tblProgramacionRutas e
    left join rh.tblEmpleadosMaster c with(nolock) on c.IDEmpleado=e.IDEmpleado 
    --where c.Vigente=1 
             


    update e   set e.TieneAusentismo= case when ie.IDEmpleado is null then 0 else 1 end  ,e.DescripcionAusentismo=isnull(ci.Descripcion,'')
    from @tblProgramacionRutas e
        left join  Asistencia.tblIncidenciaEmpleado  ie with(nolock) on ie.IDEmpleado=e.IDEmpleado and ie.Fecha=e.FechaProgramada
        left join  Asistencia.tblCatIncidencias ci with(nolock) on ci.IDIncidencia = ie.IDIncidencia 
    where (ci.EsAusentismo = 1)  and e.Vigente=1
                   

    update e set e.IDHorarioEmpleado= h.IDHorario,
    DescripcionHorarioEmpleado=ch.Descripcion
    from @tblProgramacionRutas e
    inner join Asistencia.tblHorariosEmpleados h with(nolock) on h.IDEmpleado=E.IDEmpleado and h.Fecha=e.FechaProgramada
    inner join Asistencia.tblCatHorarios ch with(nolock) on ch.IDHorario=h.IDHorario
    where e.Vigente=1 --and TieneAusentismo is null 


    UPDATE e SET 
        e.EncontroHorarioRuta=  case when hd.IDHorario is null then 0 else 1 end  ,
        e.HoraSalida = h.HoraSalida ,
        e.HoraLlegada =h.HoraLlegada ,
        e.IDRutaHorario=h.IDRutaHorario             
    from @tblProgramacionRutas e
    left join Transporte.tblCatRutasHorarios  h with(nolock) on h.IDRuta=@IDRuta
    left join Transporte.tblCatRutasHorariosDetalle  hd with(nolock) on hd.IDRutaHorario=h.IDRutaHorario  and hd.IDHorario=e.IDHorarioEmpleado
    where IDHorarioEmpleado is not null  and hd.IDRutaHorarioDetalle is not null

    update @tblProgramacionRutas  set Asignado=1 
    where Vigente=1 and TieneAusentismo is null and EncontroHorarioRuta=1

    update s set ConcatHorariosEmpleados =  ( SELECT '[' + cast(h.HoraEntrada as varchar(5)) +' - '+ cast(h.HoraSalida as varchar(5)) +']' AS 'data()'
                                                        FROM Transporte.tblCatRutasHorariosDetalle r
                                                        inner join Asistencia.tblCatHorarios h on r.IDHorario=h.IDHorario
                                                        WHERE r.IDRutaHorario=s.IDRutaHorario
                                                        FOR XML PATH('')  )
    from @tblProgramacionRutas s
    where IDRutaHorario is not null


    if @Afectar =1 
    begin 

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

            select t.IDRuta,t.FechaProgramada as Fecha,t.HoraLlegada,t.HoraSalida,cr.KMRuta,@IDUsuario [IDUsuario],IDRutaHorario 
            into #TempRutasProgramadas
            from @tblProgramacionRutas t
            inner join Transporte.tblCatRutas cr with(nolock) on cr.IDRuta= t.IDRuta                    
            where t.Asignado=1
            GROUP by t.FechaProgramada,t.HoraLlegada,t.HoraSalida,cr.KMRuta,t.IDRuta,IDRutaHorario


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
            from @tblProgramacionRutas s 
            inner join @archive a on s.FechaProgramada =a.Fecha and s.IDRuta=a.IDRuta and a.IDRutaHorario=s.IDRutaHorario


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
            DELETE;
    end

    select * From @tblProgramacionRutas e       
    WHERE Vigente=1
    order by  FechaProgramada,Asignado desc,EncontroHorarioRuta desc ,TieneAusentismo desc , IDRutaHorario
        
END
GO
