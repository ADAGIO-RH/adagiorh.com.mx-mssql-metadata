USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Reorganiza el Orden de cálculo de los conceptos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROC [Nomina].[spActualizarOrdenImpresion](
	   @IDConcepto int 
	   ,@OldIndex int  
	   ,@NewIndex int 
	   ,@IDUsuario int = 1
    )
    as

    declare 
		@i int = 1;

    if OBJECT_ID('tempdb..#tblTempConceptos') is not null
	   drop table #tblTempConceptos;

    if OBJECT_ID('tempdb..#tblTempConceptos1') is not null
	   drop table #tblTempConceptos1;

	

    if ((@NewIndex < @OldIndex) or (@OldIndex = 0))
    begin
		  select IDConcepto,Impresion,Orden, ROW_NUMBER() over(order by Orden asc) as ID
		  INTO #tblTempConceptos
		  From dbo.ordenPayroll
		  where Orden >= @NewIndex and IDConcepto <> @IDConcepto;

		  update dbo.ordenPayroll
			 set Orden = @NewIndex
		  where IDConcepto=@IDConcepto

		  while exists(select 1 from #tblTempConceptos where ID >= @i)
		  begin
			 select @IDConcepto=IDConcepto from #tblTempConceptos where  ID=@i
			 set @NewIndex = @NewIndex+1

			 update dbo.ordenPayroll
				set Orden = @NewIndex
			 where IDConcepto=@IDConcepto
		  
			 select @i=@i+1;
		  end;		
    end else
    begin
		  select IDConcepto,Impresion,Orden, ROW_NUMBER() over(order by Orden asc) as ID
		  INTO #tblTempConceptos1
		  from dbo.ordenPayroll
		  where (Orden between @OldIndex and @NewIndex) and IDConcepto <> @IDConcepto;

		  update dbo.ordenPayroll
			 set Orden = @NewIndex
		  where IDConcepto=@IDConcepto

		  while exists(select 1 from #tblTempConceptos1 where ID >= @i)
		  begin
			 select @IDConcepto=IDConcepto from #tblTempConceptos1 where  ID=@i

			 update dbo.ordenPayroll
				set Orden =@OldIndex
			 where IDConcepto = @IDConcepto

			 set @OldIndex = @OldIndex+1
			 
             select @i=@i+1;
		  end;
    end;



	
GO
