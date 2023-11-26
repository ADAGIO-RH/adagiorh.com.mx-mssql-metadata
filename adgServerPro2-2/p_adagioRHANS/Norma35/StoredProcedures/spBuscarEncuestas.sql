USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarEncuestas]
(
	@IDEncuesta int = 0,
	@PageNumber int = 1,
	@PageSize int = 2147483647,
	@IDUsuario int
)
AS
BEGIN

	declare @TotalPaginas int = 0
		,@NORMA350001 bit = 0
	  ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if exists(
		select top 1 1 
		from Seguridad.tblPermisosEspecialesUsuarios pes with (nolock)	
			join App.tblCatPermisosEspeciales cpe with (nolock) on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'NORMA350001')
	begin
		set @NORMA350001 = 1
	end;

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if OBJECT_ID('tempdb..#tempEncuestas') is not null drop table #tempEncuestas;

	SELECT 
		E.IDEncuesta
		,E.IDCatEncuesta
		,CE.Nombre as CatEncuesta
		,E.NombreEncuesta as NombreEncuesta
		,E.FechaIni
		,E.FechaFin
		,ISNULL(e.IDEmpresa, 0) as IDEmpresa
		,Emp.NombreComercial as Empresa
		,ISNULL(E.IDSucursal,0) as IDSucursal
		,S.Descripcion as Sucursal
		,ISNULL(E.IDCliente,0) as IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,ISNULL(E.CantidadEmpleados, 0) as CantidadEmpleados
		,ISNULL(E.EsAnonimo, 0) as EsAnonimo
		,ISNULL(E.IDCatEstatus,0) as IDCatEstatus
		,Est.Descripcion as CatEstatus
		,E.FechaCreacion 
		,(select count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = E.IDEncuesta and IDCatEstatus = 3 ) as EncuestasCompletadas 
		,((select count(*) from Norma35.tblEncuestasEmpleados where IDEncuesta = E.IDEncuesta and IDCatEstatus = 3 )/ 
			case when ISNULL(E.CantidadEmpleados, 1) = 0 then 1 else ISNULL(E.CantidadEmpleados, 1) end )* 100 as PorcentajeCompletado
		,ISNULL(u.IDUsuario,0) as IDUsuario
		,ISNULL(u.Cuenta,'SIN USUARIO') as Usuario
	into #tempEncuestas
	FROM Norma35.tblEncuestas E with (nolock)
		inner join Norma35.tblCatEncuestas CE with (nolock)
			on E.IDCatEncuesta = CE.IDCatEncuesta
		Left join RH.tblEmpresa Emp with (nolock)
			on Emp.IdEmpresa = e.IDEmpresa
		left join RH.tblCatSucursales S with (nolock)
			on e.IDSucursal = S.IDSucursal
		left join RH.tblCatClientes C with (nolock)
			on e.IDCliente = C.IDCliente
		inner join Norma35.tblCatEstatus Est with (nolock)
			on Est.IDCatEstatus = E.IDCatEstatus
		left join Seguridad.tblUsuarios U with (nolock)
			on E.IDUsuario = U.IDUsuario
	WHERE ((E.IDEncuesta = @IDEncuesta) or (isnull(@IDEncuesta,0) = 0))
		AND ((isnull(E.IDUsuario,0) = @IDUsuario) OR (@NORMA350001 = 1))

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempEncuestas

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempEncuestas
		order by IDEncuesta desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END;
GO
