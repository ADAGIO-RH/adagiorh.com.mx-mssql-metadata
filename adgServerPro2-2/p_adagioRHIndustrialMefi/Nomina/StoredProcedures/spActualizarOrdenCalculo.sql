USE [p_adagioRHIndustrialMefi]
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
CREATE PROC [Nomina].[spActualizarOrdenCalculo](
	   @IDConcepto int 
	   ,@OldIndex int  
	   ,@NewIndex int 
	   ,@IDUsuario int = 1
    )
    as

    declare 
		@i int = 1, 
		@Total int = 0,
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spActualizarOrdenCalculo]',
		@Tabla		varchar(max) = '[Nomina].[tblCatConceptos]',
		@Accion		varchar(20)	= 'UPDATE';

    if OBJECT_ID('tempdb..#tblTempConceptos') is not null
	   drop table #tblTempConceptos;

    if OBJECT_ID('tempdb..#tblTempConceptos1') is not null
	   drop table #tblTempConceptos1;

	select @OldJSON = '['+ STUFF(
                        (  select ','+ a.JSON
							from [Nomina].[tblCatConceptos] b
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.Codigo, b.Descripcion,b.OrdenCalculo For XML Raw)) ) a
												FOR xml path('')
                        )
                        , 1
                        , 1
                        , ''
						)
						+']'

    if ((@NewIndex < @OldIndex) or (@OldIndex = 0))
    begin
		  select IDConcepto,Codigo,Descripcion,OrdenCalculo, ROW_NUMBER() over(order by OrdenCalculo asc) as ID
		  INTO #tblTempConceptos
		  from Nomina.tblCatConceptos
		  where OrdenCalculo >= @NewIndex and IDConcepto <> @IDConcepto;

		  update Nomina.tblCatConceptos
			 set OrdenCalculo = @NewIndex
		  where IDConcepto=@IDConcepto

		  while exists(select 1 from #tblTempConceptos where ID >= @i)
		  begin
			 select @IDConcepto=IDConcepto from #tblTempConceptos where  ID=@i
			 set @NewIndex = @NewIndex+1

			 update Nomina.tblCatConceptos
				set OrdenCalculo = @NewIndex
			 where IDConcepto=@IDConcepto
		  
			 select @i=@i+1;
		  end;		
    end else
    begin
		  select IDConcepto,Codigo,Descripcion,OrdenCalculo, ROW_NUMBER() over(order by OrdenCalculo asc) as ID
		  INTO #tblTempConceptos1
		  from Nomina.tblCatConceptos
		  where (OrdenCalculo between @OldIndex and @NewIndex) and IDConcepto <> @IDConcepto;

		  update Nomina.tblCatConceptos
			 set OrdenCalculo = @NewIndex
		  where IDConcepto=@IDConcepto

		  while exists(select 1 from #tblTempConceptos1 where ID >= @i)
		  begin
			 select @IDConcepto=IDConcepto from #tblTempConceptos1 where  ID=@i

			 update Nomina.tblCatConceptos
				set OrdenCalculo = @OldIndex
			 where IDConcepto=@IDConcepto

			 set @OldIndex = @OldIndex+1

			 select @i=@i+1;
		  end;
    end;

	select @NewJSON = '['+ STUFF(
                        (  select ','+ a.JSON
							from [Nomina].[tblCatConceptos] b
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.Codigo, b.Descripcion,b.OrdenCalculo For XML Raw)) ) a
												FOR xml path('')
                        )
                        , 1
                        , 1
                        , ''
						)
						+']'

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
GO
