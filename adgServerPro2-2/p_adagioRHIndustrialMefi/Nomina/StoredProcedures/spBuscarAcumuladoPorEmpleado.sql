USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca el acumulado por Colaborador y Ejercicio
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-09-23
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAcumuladoPorEmpleado] (
	@IDEmpleado int
	,@Ejercicio int
	,@IDPeriodoInicial int = 0
	,@IDPeriodoFinal int = 0
	,@IDsTiposConceptos varchar(100) = null
	,@IDUsuario int
) as

	DECLARE  
		@DinamicColumns nvarchar(max)
		,@DinamicColumnsISNULL nvarchar(max)
		,@DinamicColumnsTotal nvarchar(max)
		,@query  AS NVARCHAR(MAX)

	/*
	 set @DinamicColumns= (SELECT SUBSTRING(
		(SELECT ',[' + CONVERT(varchar, MES_ACUMULACION) +']'
		from tblPeriodos
		where EJERCICIO = 2014 AND clave_tipo_nomina  = '001'
		FOR XML PATH('')),2,200000)
		);
	*/

	select @DinamicColumns='[ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE]'
		  ,@DinamicColumnsISNULL= 'isnull([ENERO],0) as ENERO,isnull([FEBRERO],0) as FEBRERO,isnull([MARZO],0) as MARZO,isnull([ABRIL],0) as ABRIL,isnull([MAYO],0) as MAYO,isnull([JUNIO],0) as JUNIO,isnull([JULIO],0) as JULIO,isnull([AGOSTO],0) as AGOSTO,isnull([SEPTIEMBRE],0) as SEPTIEMBRE,isnull([OCTUBRE],0) as OCTUBRE,isnull([NOVIEMBRE],0) as NOVIEMBRE,isnull([DICIEMBRE],0) as DICIEMBRE'
		  ,@DinamicColumnsTotal = ',isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0) + isnull([ABRIL],0) + isnull([MAYO],0) + isnull([JUNIO],0) + isnull([JULIO],0) + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0) + isnull([OCTUBRE],0) + isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL'

	SELECT Codigo
			,IDTipoConcepto
			,CONCEPTO
			,isnull([ENERO],0) as ENERO
			,isnull([FEBRERO],0) as FEBRERO
			,isnull([MARZO],0) as MARZO
			,isnull([ABRIL],0) as ABRIL
			,isnull([MAYO],0) as MAYO
			,isnull([JUNIO],0) as JUNIO
			,isnull([JULIO],0) as JULIO
			,isnull([AGOSTO],0) as AGOSTO
			,isnull([SEPTIEMBRE],0) as SEPTIEMBRE
			,isnull([OCTUBRE],0) as OCTUBRE
			,isnull([NOVIEMBRE],0) as NOVIEMBRE
			,isnull([DICIEMBRE],0) as DICIEMBRE
			,isnull([ENERO],0) + isnull([FEBRERO],0) + isnull([MARZO],0) + isnull([ABRIL],0) + isnull([MAYO],0) + 
			 isnull([JUNIO],0) + isnull([JULIO],0) + isnull([AGOSTO],0) + isnull([SEPTIEMBRE],0) + isnull([OCTUBRE],0) + 
			 isnull([NOVIEMBRE],0) + isnull([DICIEMBRE],0) as TOTAL 
		from 
             (
				select c.Codigo,c.IDTipoConcepto,c.DESCRIPCION as CONCEPTO,m.Nombre as Mes,isnull(dp.ImporteTotal1,0) as Total,c.OrdenCalculo
				from Nomina.tblDetallePeriodo dp 
					inner join Nomina.tblCatPeriodos P on dp.IDPeriodo = P.IDPeriodo and isnull(p.Cerrado,0)  =1
					inner join Utilerias.tblMeses m on P.IDMes = m.IDMes
					left join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto
				where dp.IDEmpleado = @IDEmpleado  AND 
					  P.ejercicio = @Ejercicio  AND 
					  (c.IDTipoConcepto in (select item from App.Split(@IDsTiposConceptos,',')) or ISNULL(@IDsTiposConceptos,'') = '') AND 
					  (dp.IDPeriodo between isnull(@IDPeriodoInicial,0) and isnull(@IDPeriodoFinal,0) or (isnull(@IDPeriodoInicial,0) = 0 and isnull(@IDPeriodoFinal,0) = 0))         
            ) x
            pivot 
            (
               SUM( Total )
                for Mes in ([ENERO],[FEBRERO],[MARZO],[ABRIL],[MAYO],[JUNIO],[JULIO],[AGOSTO],[SEPTIEMBRE],[OCTUBRE],[NOVIEMBRE],[DICIEMBRE])
            ) p order by OrdenCalculo asc

--set @query = 'SELECT Codigo,IDTipoConcepto,CONCEPTO,' + @DinamicColumnsISNULL + @DinamicColumnsTotal +' from 
--             (
--				select c.Codigo,c.IDTipoConcepto,c.DESCRIPCION as CONCEPTO,m.Nombre as Mes,isnull(dp.ImporteTotal1,0) as Total,c.OrdenCalculo
--				from Nomina.tblDetallePeriodo dp 
--					inner join Nomina.tblCatPeriodos P on dp.IDPeriodo = P.IDPeriodo
--					inner join Utilerias.tblMeses m on P.IDMes = m.IDMes
--					left join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto
--				where dp.IDEmpleado = '+CAST(@IDEmpleado as varchar)
--					+'  AND P.ejercicio = '+CAST(@Ejercicio as varchar)          
--					+'  AND (c.IDTipoConcepto in ('+ (select item from App.Split(isnull(@IDsTiposConceptos,''),',')) +') or '+ isnull(@IDsTiposConceptos,'') + ' = '''') '        
--					+'  AND (dp.IDPeriodo = '+CAST(@IDPeriodo as varchar) +' or '+CAST(@IDPeriodo as varchar) +' = 0)         
--            ) x
--            pivot 
--            (
--               SUM( Total )
--                for Mes in (' + @DinamicColumns + ')
--            ) p order by OrdenCalculo asc'

--print @DinamicColumns
--print isnull(@query,'Algo')
--execute(@query)
GO
