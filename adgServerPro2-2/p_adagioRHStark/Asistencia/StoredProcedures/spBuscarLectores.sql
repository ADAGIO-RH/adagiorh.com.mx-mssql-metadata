USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS LECTORES
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-10-20			Aneudy Abreu	Se agregaron los campos IDCliente y Cliente
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarLectores]
(
	 @IDLector int = null
	,@IDUsuario		int = 1
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query		varchar(max) = ''
)
AS
BEGIN

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#temptblLectores') is not null drop table #temptblLectores;


	SELECT 
		 L.IDLector
		,L.Lector
		,L.CodigoLector
		,L.PasswordLector
		,L.IDTipoLector
		,TL.TipoLector
		,isnull(L.IDZonaHoraria,0) as IDZonaHoraria
		,isnull(z.Name,'SIN DEFINIR') as ZonaHoraria
		,l.IP as IP
		,l.Puerto as Puerto
		,l.Estatus as Estatus
		,isnull(l.EsComedor,0) as EsComedor
		,isnull(l.Comida,0) as Comida
		,isnull(L.IDCliente,0) IDCliente
		,isnull(c.NombreComercial,'Sin cliente asignado') as Cliente
        ,L.Master as [Master]
		,l.NumeroSerial as [NumeroSerial]
		,ROW_NUMBER()OVER(ORDER BY IDLECTOR ASC) AS ROWNUMBER
	INTO #temptblLectores
	from Asistencia.tblLectores L
		INNER JOIN Asistencia.tblCatTiposLectores TL
			on L.IDTipoLector = TL.IDTipoLector
		LEFT JOIN RH.tblCatClientes c on c.IDCliente = L.IDCliente
		LEFT JOIN Tzdb.Zones Z
			on Z.Id = L.IDZonaHoraria
	WHERE ((IDLector = @IDLector) OR (@IDLector IS NULL))
			and (coalesce(@query,'') = '' or coalesce(L.Lector, '')+' '+coalesce(L.CodigoLector, '') like '%'+@query+'%')


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #temptblLectores

	select @TotalRegistros = cast(COUNT(IDLector) as decimal(18,2)) from #temptblLectores		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #temptblLectores
		order by Lector asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
