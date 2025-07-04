USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [RH].[spBuscarValorCamposDinamicos](
    @IDEmpleado int,
    @filtroTablas varchar(max) = null,
    @IDUsuario int
) AS
BEGIN

    DECLARE 
		@IDIdioma varchar(225),
		@QuerySelect VARCHAR(max),
		@ClaveEmpleado VARCHAR(50),
		@total  int,
		@row int,
		@json varchar(max),
		@totalCamposGenerales int, 
		@totalCamposFinales int 
	;
	--set @filtroTablas = case 
	--						when isnull(@filtroTablas, '') = '' then '[rh].[tblEmpleadosMaster]' else @filtroTablas end

	set @filtroTablas = '[Comunicacion].[vwDatosEmpleadosMaster]'

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'); 
	
    declare @tblCamposDinamicos table(
		[KEY] varchar(max),
		[VALUE] varchar(max),
        [TIPO] int 
    );
    
    declare @tblTablaValores table(
        [Tabla] varchar(100),
        [Campos] varchar(max),
        [RowNumber] int
    )    

    select @ClaveEmpleado = ClaveEmpleado from RH.tblEmpleadosMaster where IDEmpleado=@IDEmpleado

    insert into @tblTablaValores (Tabla,Campos,RowNumber)
	SELECT 
		Tabla,STRING_AGG(Campo, ', ') AS Campos,ROW_NUMBER()over(order by Tabla)
	FROM  App.tblCatCamposDinamicos s 
	where (
		s.Tabla in (Select item from App.Split(@filtroTablas,','))
		or 
		isnull(@filtroTablas, '') = ''
	)
	group by Tabla

	select  @total=count(*) from @tblTablaValores
	set @row=1	    
    
	while (@row <=@total)
    BEGIN		
        declare @campos varchar(max)
        declare @tabla VARCHAR(100)
		select 
            @campos=s.Campos,
            @tabla= s.Tabla
        from @tblTablaValores s where s.RowNumber=@row
		
		SELECT @QuerySelect= CONCAT(' Select isnull(B.[Key],'''') 
			                    ,B.[Value],1
		                        From  (
			                        SELECT '  , @campos,' FROM ',@tabla,' WHERE  IDEmpleado= ',@IDEmpleado,				                    
		                        ') A
		                            Cross Apply OpenJSON(  (Select A.* For JSON Path, Without_Array_Wrapper ) ) B')        
        insert into @tblCamposDinamicos ([KEY],[VALUE],TIPO)
        exec (@querySelect  )		 				
		set @row=@row+1;
	end	
   
    select 
        @totalCamposFinales= count(*) from @tblCamposDinamicos     

    if(@totalCamposGenerales=@totalCamposFinales)
    begin 
        insert into @tblCamposDinamicos ([KEY],[VALUE],TIPO)
        select  value , '' , 2 FROM OPENJSON(@json,'$.header') 
    end

    select * From @tblCamposDinamicos
END
GO
