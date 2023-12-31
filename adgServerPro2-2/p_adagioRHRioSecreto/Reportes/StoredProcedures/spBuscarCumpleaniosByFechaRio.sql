USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Busca trabajadores cumpleaños rango.    
** Autor   : jose roman  
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-02-27    
** Paremetros  :      
  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
***************************************************************************************************/    
CREATE PROCEDURE [Reportes].[spBuscarCumpleaniosByFechaRio]  
(  @dtFiltros [Nomina].[dtFiltrosRH] Readonly  
   ,@IDUsuario int    
)  
AS  
BEGIN  

Declare --@dtFiltros [Nomina].[dtFiltrosRH]
			@lista [App].[dtFechasFull],
			@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) 
			,@FechaIni date 
			,@FechaFin date 
  



  
	select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoVigente'),'1'),','))



insert into @lista  
exec [App].[spListaFechas] @fechaIni, @fechaFin
  



  if(@IDTipoVigente = 1)
  begin
  insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
		
 select 
  E.ClaveEmpleado
  ,E.NOMBRECOMPLETO
  ,E.RFC  AS  [RFC        ]
  ,E.CURP AS  [CURP       ]
  ,E.IMSS AS  [IMSS       ]
  ,E.Departamento
  ,E.Sucursal
  ,E.Puesto
  ,E.FechaNacimiento
    from @dtEmpleados e    
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
			on FEU.IDEmpleado = E.IDEmpleado
			and FEU.IDUsuario = @IDUsuario
    where   
   ((datepart(month,e.FechaNacimiento)in(select Mes from @lista))    
   and     
   (datepart(day,e.FechaNacimiento)in (select Dia from @lista)))  	 
     
   
   order by e.ClaveEmpleado asc
   END

   
  if(@IDTipoVigente = 2)
  begin
  insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
		
 select 
   E.ClaveEmpleado
  ,E.NOMBRECOMPLETO
   ,E.RFC AS [RFC        ]
  ,E.CURP AS [CURP       ]
  ,E.IMSS AS [IMSS       ]
  ,E.Departamento
  ,E.Sucursal
  ,E.Puesto
  ,E.FechaNacimiento
    from [RH].[tblEmpleadosMaster] e    
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
			on FEU.IDEmpleado = E.IDEmpleado
			and FEU.IDUsuario = @IDUsuario
    where   e.Vigente = 0
  and    
   ((datepart(month,e.FechaNacimiento)in(select Mes from @lista))    
   and     
   (datepart(day,e.FechaNacimiento)in (select Dia from @lista)))   
     
   
   order by e.ClaveEmpleado asc
   END
END
GO
