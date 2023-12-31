USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los lectores de los empleados
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spBuscarEmpleadosLector]  (  
	@IDLector int  
	,@IDUsuario int = 1
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
)  
AS  
BEGIN  

	SET FMTONLY OFF;


	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@empleados [RH].[dtEmpleados]    
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;


	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT   
		le.IDLectorEmpleado  
		,em.IDEmpleado  
		,em.ClaveEmpleado  
		,em.NOMBRECOMPLETO  
		,em.Puesto  
		,em.Departamento  
		,em.Sucursal  
		,l.IDLector as IDLector  
		,l.Lector as Lector 
		into #tempEmpleados
	FROM rh.tblEmpleadosMaster em with (nolock)
		inner join Asistencia.tblLectoresEmpleados le with (nolock) on em.IDEmpleado = le.IDEmpleado  
		inner join Asistencia.tblLectores l with (nolock) on le.IDLector = l.IDLector  
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
	where l.IDLector = @IDLector  

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @empleados

	select @TotalRegistros = COUNT(IDEmpleado) from #tempEmpleados		

	select 
		*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempEmpleados
	order by 
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc,		
		ClaveEmpleado asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
   

END;
GO
