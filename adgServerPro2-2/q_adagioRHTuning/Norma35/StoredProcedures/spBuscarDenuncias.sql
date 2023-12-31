USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Norma35].[spBuscarDenuncias] 
	-- Add the parameters for the stored procedure here
@IDUsuario int =0
    ,@IDTipoDenuncia int= 0
    ,@IDTipoDenunciado int =0
	,@IDEmpleadoDenunciante int = 0
    ,@FechaInicio DATETIME =null
    ,@FechaFin DATETIME =null
    ,@IDEstatusDenuncia  int =0
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query		varchar(max) = ''
AS
BEGIN
    declare      @TotalPaginas int = 0 
                ,@TotalRegistros decimal(18,2) = 0.00 ;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempDenuncias') is not null drop table #tempDenuncias;

    select 	de.IDDenuncia
			,tiposdenuncia.Descripcion as [TipoDenunciaDescripcion]  
			,estd.Descripcion as  [EstatusDescripcion]
			,estd.EstatusColor
			,estd.EstatusBackground 			
			,de.EsAnonima
            ,de.IDTipoDenuncia
            ,de.IDEmpleadoDenunciante 			
			,de.FechaEvento
			,de.FechaRegistro,
			CASE WHEN de.IDTipoDenunciado = 1 /*DENUNCIAR UNA SITUACIÓN EN ESPECÍFICO.*/ THEN ('EVENTO: ' + UPPER(de.Denunciados) )
				 WHEN de.IDTipoDenunciado = 2 /*DENUNCIAR A UN COLABORADOR.*/ THEN (select CONCAT(emp.Nombre,' ',emp.Paterno) from RH.tblEmpleados  emp where IDEmpleado = cast(de.Denunciados as int))
				 WHEN de.IDTipoDenunciado = 3 /*DENUNCIAR A VARIOS COLABORADORES..*/ THEN ( select
																						   distinct  
																							stuff((
																								select ',' + CONCAT(emp.Nombre,' ',emp.Paterno)
																								from RH.tblEmpleados emp
																								where emp.IDEmpleado in ( SELECT item from [App].[Split](de.Denunciados,',') )
																								order by emp.IDEmpleado
																								for xml path('')
																							),1,1,'')
																						from RH.tblEmpleados
																						group by IDEmpleado)
			END AS Titulo ,
            ed.IDEmpleado  [EmpleadoDenuncianteIDEmpleado] ,
            ed.NOMBRECOMPLETO [EmpleadoDenuncianteNombreCompleto] ,
            ed.Departamento [EmpleadoDenuncianteDepartamento],
            ed.ClaveEmpleado [EmpleadoDenuncianteClaveEmpleado],

            edd.IDEmpleado     [EmpleadoDenunciadoIDEmpleado] ,
            edd.NOMBRECOMPLETO [EmpleadoDenunciadoNombreCompleto] ,
            edd.Departamento   [EmpleadoDenunciadoDepartamento],
            edd.ClaveEmpleado  [EmpleadoDenunciadoClaveEmpleado]
    INTO #tempDenuncias	
	FROM Norma35.tblDenuncias as de	
	LEFT JOIN [Norma35].[tblCatEstatusDenuncia] as estd on estd.IDEstatusDenuncia=de.IDEstatusDenuncia	
    LEFT JOIN [RH].tblEmpleadosMaster as ed on ed.IDEmpleado = de.IDEmpleadoDenunciante
	LEFT JOIN Norma35.tblCatTiposDenuncias tiposdenuncia on tiposdenuncia.IDTipoDenuncia=de.IDTipoDenuncia
    LEFT JOIN RH.tblEmpleadosMaster as edd on edd.IDEmpleado in (Select  item from App.Split( iif(de.IDTipoDenunciado in(2,3),de.Denunciados,''),','))  and de.IDTipoDenunciado in (2,3) 
	where  
        ([de].IDEstatusDenuncia = @IDEstatusDenuncia or isnull(@IDEstatusDenuncia,0) = 0) and
        ([de].IDTipoDenuncia = @IDTipoDenuncia or isnull(@IDTipoDenuncia,0) = 0) and
        ([de].IDTipoDenunciado = @IDTipoDenunciado or isnull(@IDTipoDenunciado,0) = 0) and
        ( ([de].FechaRegistro BETWEEN @FechaInicio  and @FechaFin   or isnull(@FechaInicio,0) = 0)  or 
          ([de].FechaEvento BETWEEN @FechaInicio  and @FechaFin   or isnull(@FechaInicio,0) = 0) ) and   
		([de].IDEmpleadoDenunciante = @IDEmpleadoDenunciante or isnull(@IDEmpleadoDenunciante,0) = 0) 
		and

		(coalesce(@query,'') = '' or coalesce(de.DescripcionHechos, '') like '%'+@query+'%')
        order by FechaEvento
        

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempDenuncias

	select @TotalRegistros = cast(COUNT([IDDenuncia]) as decimal(18,2)) from #tempDenuncias		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempDenuncias
		order by [IDTipoDenuncia] asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


	 
END
GO
