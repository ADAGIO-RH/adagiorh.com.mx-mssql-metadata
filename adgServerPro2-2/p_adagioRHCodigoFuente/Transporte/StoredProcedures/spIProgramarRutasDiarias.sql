USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	
-- =============================================
CREATE PROCEDURE [Transporte].[spIProgramarRutasDiarias]
    -- Add the parameters for the stored procedure here	
AS
BEGIN
    
        DECLARE 
    		@IDNotificacion int 
		    ,@IDTipoNotificacion varchar (255)                    
		    ,@Htmlbody varchar (max)                    
		    ,@Subject varchar (max)   
    		,@IDIdioma varchar(20) = 'esmx'
            ,@i int = 0
            ,@FechaProgramacion date 
            ,@IDUsuario int =1
            ,@Fechas [App].[dtFechas]   
            ,@IDTIPO_REFERENCIA_TRANSPORTE varchar(max)



        SET @IDTIPO_REFERENCIA_TRANSPORTE ='[Transporte].[tblRutasProgramadas]'


        SET @FechaProgramacion=getdate()            
        set @IDTipoNotificacion='ProgramacionDiariaTransporte'
        set @Subject='Programación de rutas'
        set @Htmlbody =FORMATMESSAGE( N'<p>Hola, se han programado las rutas del día %s</p> <br>                            
                    <h1>Información de la programación</h1><br>',CONVERT(VARCHAR(10),@FechaProgramacion,101));
                    
        if object_id('tempdb..#temCatalogoRutas') is not null drop table #tempCatalogoRutas;

        INSERT @Fechas  
        EXEC app.spListaFechas @FechaIni =@FechaProgramacion, @FechaFin = @FechaProgramacion         

        select *,ROW_NUMBER()OVER( ORDER BY (SELECT NULL)) AS rownumber 
	        INTO #tempCatalogoRutas
	    from Transporte.tblCatRutas  
	    
        
        select @i = min(rownumber) from #tempCatalogoRutas
        while exists(select top 1 1 from #tempCatalogoRutas where rownumber >= @i)
        begin
            

            declare @DescripcionRuta varchar(100);                
            declare @IDRuta int 

            select  @IDRuta=r.IDRuta  ,
                    @DescripcionRuta= r.ClaveRuta +' - '+r.Descripcion
            from #tempCatalogoRutas r where rownumber = @i

            PRINT 'ruta: ' + CAST(@IDRuta AS VARCHAR(10))
            
            BEGIN -- SP TRANSPORTE.SPIRUTAPROGRAMADA
                                            
                DECLARE @tblProgramacionRutas as table ( 
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
                ); 
                
                if object_id('tempdb..#tempDiasVigencias')	is not null drop table #tempDiasVigencias;  
                create table #tempDiasVigencias (
                    IDEmpleado int
                    ,Fecha date
                    ,Vigente bit
                );

                insert into @tblProgramacionRutas ( [IDRuta],[IDRutaPersonal],[ClaveRuta],[Descripcion] ,[Destino],[Origen],[KMRuta], [IDEmpleado], [Nombres], [Apellidos], [FechaProgramada])
                SELECT  r.IDRuta , RP.IDRutaPersonal ,R.ClaveRuta,R.Descripcion,R.Descripcion,R.Origen,R.KMRuta, rp.IDEmpleado,rp.Nombres,rp.Apellidos,f.Fecha  
                From Transporte.tblRutasPersonal rp
                    inner join Transporte.tblCatRutas r on r.IDRuta = rp.IDRuta1  
                    inner join @Fechas f on f.Fecha between rp.FechaInicio and rp.FechaFin 
                where rp.IDRuta1=@IDRuta
                    
                    

                declare @dtEmpleados RH.dtEmpleados
            
                insert @dtEmpleados(IDEmpleado) 
                select IDEmpleado from @tblProgramacionRutas 


                insert #tempDiasVigencias
                exec RH.spBuscarListaFechasVigenciaEmpleado  
                @dtEmpleados = @dtEmpleados 
                ,@Fechas = @Fechas
                ,@IDUsuario = @IDUsuario 
                    
                    
                update e   set e.Vigente=c.Vigente
                from @tblProgramacionRutas e
                    inner join #tempDiasVigencias c on c.IDEmpleado=e.IDEmpleado and c.Fecha=e.FechaProgramada
                
                
                delete from #tempDiasVigencias                

                update e   set e.ClaveEmpleado=isnull(c.ClaveEmpleado,'EXTERNO')
                from @tblProgramacionRutas e
                    left join rh.tblEmpleadosMaster c on c.IDEmpleado=e.IDEmpleado                 
                --where c.Vigente=1  -> para mostrar solo vigentes en el reporte
                        
                update e   set e.TieneAusentismo= case when ie.IDEmpleado is null then 0 else 1 end  ,e.DescripcionAusentismo=isnull(ci.Descripcion,'')
                from @tblProgramacionRutas e
                    left join  Asistencia.tblIncidenciaEmpleado  ie on ie.IDEmpleado=e.IDEmpleado and ie.Fecha=e.FechaProgramada
                    left join  Asistencia.tblCatIncidencias ci on ci.IDIncidencia = ie.IDIncidencia 
                where (ci.EsAusentismo = 1)  and e.Vigente=1 
                    
                    
                update e set 
                    e.IDHorarioEmpleado= h.IDHorario, 
                    DescripcionHorarioEmpleado=ch.Descripcion
                from @tblProgramacionRutas e
                    inner join Asistencia.tblHorariosEmpleados h on h.IDEmpleado=E.IDEmpleado and h.Fecha=e.FechaProgramada
                    inner join Asistencia.tblCatHorarios ch on ch.IDHorario=h.IDHorario
                where e.Vigente=1 --and TieneAusentismo is null 
            
                UPDATE e SET 
                    e.EncontroHorarioRuta=  case when hd.IDHorario is null then 0 else 1 end  ,
                    e.HoraSalida = h.HoraSalida ,
                    e.HoraLlegada =h.HoraLlegada ,
                    e.IDRutaHorario=h.IDRutaHorario             
                from @tblProgramacionRutas e
                    left join Transporte.tblCatRutasHorarios  h on h.IDRuta=@IDRuta
                    left join Transporte.tblCatRutasHorariosDetalle  hd on hd.IDRutaHorario=h.IDRutaHorario  and hd.IDHorario=e.IDHorarioEmpleado
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
                
                declare @ThorariosRuta int;
                declare @TpersonasRuta int;
                declare @TPersonasAsignadas int;
                declare @TPersonasAusentismos int;
                declare @TPersonasNoAsignadas int;
                
                set @ThorariosRuta= isnull((SELECT  count(distinct IDRutaHorario) as total from @tblProgramacionRutas where IDRutaHorario is not null),0)
                set @TpersonasRuta = isnull((SELECT  count(*) as total from @tblProgramacionRutas  where Vigente=1),0)
                set @TPersonasAsignadas = isnull((SELECT  count(*) as total from @tblProgramacionRutas where Asignado=1 ),0)
                set @TPersonasAusentismos = isnull((SELECT  count(*) as total from @tblProgramacionRutas where TieneAusentismo=1 ),0)                                
                set @HtmlBody+=FORMATMESSAGE('<h2>Ruta: %s </h2>                    
                                <table id=''table-detalle''>
                                    <tr> <td>Horarios Programados</td> <td>%i</td> </tr>  
                                    <tr> <td>Total de personas que tiene la ruta:</td> <td>%i</td> </tr>                  
                                    <tr> <td>Total de personas asignadas</td> <td>%i</td> </tr>                  
                                    <tr> <td>Total de ausentismos</td> <td>%i</td> </tr>                                           
                                    <tr> <td>Total de personas no asignadas</td> <td>%i</td> </tr>                                   
                                </table>', @DescripcionRuta,@ThorariosRuta,@TpersonasRuta,@TPersonasAsignadas,@TPersonasAusentismos, (@TpersonasRuta-(@TPersonasAsignadas+@TPersonasAusentismos) ));

                
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
                        inner join Transporte.tblCatRutas cr on cr.IDRuta= t.IDRuta                    
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
                end;                
            END                  
            
            delete  From  @tblProgramacionRutas                  
            SELECT @i = min(rownumber) from #tempCatalogoRutas where rownumber > @i;
        end;     
                
        DECLARE @listaCorreos as TABLE(
            Email varchar(100),
            IDUsuario int 
        );

        insert @listaCorreos  (Email,IDUsuario)
        select CC.Email ,u.IDUsuario
        from [RH].[tblContactosEmpleadosTiposNotificaciones] n
        inner join Utilerias.fnBuscarCorreosEmpleados(@IDTipoNotificacion) cc on cc.IDEmpleado=n.IDEmpleado
        left join Seguridad.tblUsuarios u on u.IDEmpleado=n.IDEmpleado
        where IDTipoNotificacion=@IDTipoNotificacion

        insert @listaCorreos (Email,IDUsuario)
        SELECT Utilerias.fnGetCorreoEmpleado(null,n.IDUsuario,@IDTipoNotificacion),n.IDUsuario from 
        App.tblContactosUsuariosTiposNotificaciones n where IDTipoNotificacion=@IDTipoNotificacion


        if exists(select top 1 1 from @listaCorreos)
        begin 
            SELECT @HtmlBody       
        
            insert into App.tblNotificaciones (IDTipoNotificacion,Parametros)
            values(@IDTipoNotificacion,null)
        
            set @IDNotificacion=SCOPE_IDENTITY();

            insert into App.tblEnviarNotificacionA (IDNotifiacion,IDMedioNotificacion,Destinatario,Enviado,Parametros,TipoReferencia,IDUsuario)    
            select @IDNotificacion,  'Email',c.Email,0, '{ "subj ect":"'+@Subject+'","body":"'+REPLACE( @Htmlbody,'"','\"')+'"}',@IDTIPO_REFERENCIA_TRANSPORTE,c.IDUsuario
            from @listaCorreos c
            
        end        
END
GO
