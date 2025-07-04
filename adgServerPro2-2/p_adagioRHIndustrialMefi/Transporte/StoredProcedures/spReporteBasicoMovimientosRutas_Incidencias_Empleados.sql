USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    declare @p2 [Nomina].[dtFiltrosRH]  
    insert into @p2(Catalogo,[Value])
    values ('FechaIni','2022-10-25'),
            ('FechaFin','2022-10-25'),
            ('Departamentos',null),
            ('Sucursales',null),
            ('Puestos',null)    
    exec [Transporte].[spReporteBasicoMovimientosRutas_Incidencias_Empleados]  
    @dtFiltros=@p2,
    @IDUsuario=1
*/
CREATE PROCEDURE [Transporte].[spReporteBasicoMovimientosRutas_Incidencias_Empleados](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
)
AS
BEGIN
        SET LANGUAGE 'Spanish'; 
	    SET DATEFIRST 7;  
	    SET DATEFORMAT ymd;

        declare  @Fechas [App].[dtFechas]   
        declare @FechaIni date = null
	    declare @FechaFin date=null;
        declare @Departamentos varchar(100);
        declare @Sucursales varchar(100);
        declare @Puestos varchar(100);

	     
	    SET @FechaIni =isnull((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),convert(varchar, getdate(), 23))
        SET @FechaFin = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),convert(varchar, getdate(), 23))
        SET @Departamentos = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),'')
        SET @Sucursales = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),'')
        SET @Puestos = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),'')
        
        

        insert @Fechas  
        exec app.spListaFechas @FechaIni =@FechaIni, @FechaFin = @FechaFin
        
          if object_id('tempdb..#tempRutasProgramadasExcel') is not null drop table #tempRutasProgramadasExcel;
        create table #tempRutasProgramadasExcel(                      
            [IDEmpleado] int ,
            [ClaveEmpleado]    varchar(20),
            [NombreCompleto]    varchar(100),
            [Departamento]    varchar(100),
            [Puesto]    varchar(100),                    
            [Sucursal]    varchar(100),                    
            [RutaDescripcion]    varchar(100),                    
            [Fecha]       date,
            [StrFecha]       VARCHAR(100),
            [Vigente]      bit                    ,
            [TieneAusentismo] bit,
            [DescripcionAusentismo] VARCHAR(50),
            [TotalRows] int
        ); 
    
        if object_id('tempdb..#tempDiasVigencias')	is not null drop table #tempDiasVigencias;  

        create table #tempDiasVigencias (
		    IDEmpleado int
		    ,Fecha date
		    ,Vigente bit
	    );

        insert #tempRutasProgramadasExcel (IDEmpleado,ClaveEmpleado,NombreCompleto,Departamento,Puesto,Sucursal,Fecha,StrFecha,RutaDescripcion)
        select m.IDEmpleado,m.ClaveEmpleado,m.NOMBRECOMPLETO,m.Departamento,m.Puesto,m.Sucursal ,
        a.Fecha, upper(Format(a.Fecha, 'dddd dd  MMMM')) , concat(isnull(r1.ClaveRuta,'') , case when r1.ClaveRuta is null or r2.ClaveRuta is null then 'S/R' else '/'  end , isnull(r2.ClaveRuta,'')) as r 
          From  rh.tblEmpleadosMaster  m        
            cross join @Fechas a 
            left join Transporte.tblRutasPersonal rp on rp.IDEmpleado=m.IDEmpleado and a.Fecha BETWEEN rp.FechaInicio and rp.FechaFin
            left join Transporte.tblCatRutas r1 on r1.IDRuta=rp.IDRuta1
            left join Transporte.tblCatRutas r2 on r2.IDRuta=rp.IDRuta2        
            left join rh.tblEmpleados em on em.IDEmpleado=m.IDEmpleado
        where  (m.IDDepartamento in (Select item from App.Split(@Departamentos,',')) or @Departamentos ='')
        and (m.IDSucursal in (Select item from App.Split(@Sucursales,',')) or @Sucursales='')
        and (m.IDPuesto in (Select item from App.Split(@Puestos,',')) or @Puestos='')
        and em.RequiereTransporte=1

        

        declare @dtEmpleados RH.dtEmpleados
    
        insert @dtEmpleados(IDEmpleado) 
        select IDEmpleado from #tempRutasProgramadasExcel
        insert #tempDiasVigencias
        exec RH.spBuscarListaFechasVigenciaEmpleado  @dtEmpleados = @dtEmpleados 
                                                    ,@Fechas = @Fechas
		                                             ,@IDUsuario = @IDUsuario 

        update e   set e.Vigente=c.Vigente
        from #tempRutasProgramadasExcel e
        inner join #tempDiasVigencias c on c.IDEmpleado=e.IDEmpleado and c.Fecha=e.Fecha

        
        delete from  #tempDiasVigencias;

        DECLARE @cols AS VARCHAR(MAX),
		    @query1  AS VARCHAR(MAX),
		    @query2  AS VARCHAR(MAX),
		    @colsAlone AS VARCHAR(MAX);

	    SET @cols = STUFF((SELECT ',' +  QUOTENAME(c.StrFecha) +'AS '+ QUOTENAME(c.StrFecha)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.StrFecha,c.Fecha
				ORDER BY c.Fecha
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');


	    SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.StrFecha)
				FROM #tempRutasProgramadasExcel c
				GROUP BY c.StrFecha,c.Fecha
				ORDER BY c.Fecha
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');


    update e   set e.TieneAusentismo= case when ie.IDEmpleado is null then 0 else 1 end  ,e.DescripcionAusentismo=isnull(ci.Descripcion,'')
        from #tempRutasProgramadasExcel e
            left join  Asistencia.tblIncidenciaEmpleado  ie on ie.IDEmpleado=e.IDEmpleado and ie.Fecha=e.Fecha
            left join  Asistencia.tblCatIncidencias ci on ci.IDIncidencia = ie.IDIncidencia 
        where (ci.EsAusentismo = 1)  and e.Vigente=1

    
    

      update  e set e.TotalRows= (select count(*) from #tempRutasProgramadasExcel where IDEmpleado=e.IDEmpleado)
    from #tempRutasProgramadasExcel e



 
    delete From #tempRutasProgramadasExcel
    where IDEmpleado in (
         select distinct IDEmpleado From #tempRutasProgramadasExcel  s
            where  TotalRows= (select count(*) From #tempRutasProgramadasExcel where IDEmpleado=s.IDEmpleado and (RutaDescripcion ='S/R'))    
    )

    
        

	set @query1 = 'SELECT ClaveEmpleado [Clave Empleado],NombreCompleto [Nombre Completo],Departamento,Puesto,Sucursal,' + @cols + ' from     
				(
					select 
						ClaveEmpleado
						, NombreCompleto
                        , Departamento 
                        , Puesto
                        , Sucursal
						, StrFecha
						,  case when Vigente=0 then ''NO VIGENTE''
                                when Vigente=1 then  
                                    case when TieneAusentismo = 1 then DescripcionAusentismo else  RutaDescripcion end                                
                            end
                         as [RutaDescripcion]
						 
					from #tempRutasProgramadasExcel                    
			   ) x'

	set @query2 = '
				pivot 
				(
					 max(RutaDescripcion)
					for StrFecha in (' + @colsAlone + ')
				) p                 				                
				'	
	exec( @query1 + @query2)
        
 
END
GO
