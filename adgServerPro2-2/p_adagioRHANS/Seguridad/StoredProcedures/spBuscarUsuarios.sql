USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los usuarios registrados en la base de datos paginados y con filter
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-02-17
** Paremetros		:              


Si se modificica el resulset de este sp, es necesario actualiza el dt [Seguridad].[dtUsuarios]
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spBuscarUsuarios]
(
	@IDUsuario		int = 0
	,@IDPerfil		int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(max) = ''
)
AS
BEGIN
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempUsuarios') is not null drop table #tempUsuarios;

	Select 
		u.IDUsuario
		,isnull(u.IDEmpleado,0) as IDEmpleado
		,coalesce(e.ClaveEmpleado,'') as ClaveEmpleado
		,u.Cuenta
		,null as [Password]
		,isnull(u.IDPreferencia,0) as IDPreferencia
		,u.Nombre
		,u.Apellido
		,NombreCompleto = coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')
		,coalesce(u.Sexo,'') as Sexo
		,u.Email
		,isnull(u.Activo,0) as Activo 
		,EsColaborador = case when isnull(u.IDEmpleado,0) <> 0 then cast(1 as bit) else cast(0 as bit) end
		,isnull(e.Vigente,cast(0 as bit)) as Vigente 
		,ISNULL(U.IDPerfil,0) as IDPerfil
		,P.Descripcion as Perfil
		,'' as [URL]
		,isnull(u.Supervisor,0) as Supervisor 
		 ,isnull(candidato.IDCandidato,0) as IDCandidato 
	INTO #tempUsuarios
	from Seguridad.tblUsuarios u with (nolock) 
		left join [RH].[tblEmpleadosMaster] e with (nolock) on u.IDEmpleado = e.IDEmpleado
		inner join Seguridad.tblCatPerfiles P with (nolock) on U.IDPerfil = P.IDPerfil
		left join Reclutamiento.tblCandidatos candidato
			on Candidato.IDEmpleado = e.IDEmpleado
	Where ((u.IDUsuario = @IDUsuario) OR (@IDUsuario = 0) )
		and ( (u.IDPerfil = @IDPerfil) OR (@IDPerfil = 0) )
		and ((coalesce(@query,'') = '' or  coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '')+' '+coalesce(u.Cuenta, '')+' '+coalesce(u.Email, '') like '%'+@query+'%'))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempUsuarios

	select @TotalRegistros = cast(COUNT([IDUsuario]) as decimal(18,2)) from #tempUsuarios		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempUsuarios
		order by Cuenta asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
