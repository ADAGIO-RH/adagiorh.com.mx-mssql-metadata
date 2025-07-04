USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	
-- =============================================
/*
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
31-10-2024			Alejandro Paredes	Se cambio la tabla [RH].[tblEmpleadosMaster] por la vista [Comunicacion].[vwDatosEmpleadosMaster]
***************************************************************************************************/

CREATE PROCEDURE [Comunicacion].[spBuscarValorCamposDinamicos]
    -- Add the parameters for the stored procedure here	
    @IDUsuario int ,
    @IDEmpleado int,
    @IDAviso int,
    @filtroTablas varchar(100)
AS
BEGIN

    DECLARE @IDIdioma varchar(225)
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  
    declare @QuerySelect VARCHAR(max)
    declare @ClaveEmpleado VARCHAR(50)
    declare @tblCamposDinamicos table(
		[KEY] varchar(max),
		[VALUE] varchar(max),
        [TIPO] int ,
        [IDAviso] int    
    );
    
    DECLare @tblTablaValores table(
        [Tabla] varchar(100),
        [Campos] varchar(max),
        [RowNumber] int
    )    

    select @ClaveEmpleado = ClaveEmpleado from [Comunicacion].[vwDatosEmpleadosMaster] where IDEmpleado=@IDEmpleado

    insert into @tblTablaValores (Tabla,Campos,RowNumber)
        SELECT 
            Tabla,STRING_AGG(Campo, ', ') AS Campos,ROW_NUMBER()over(order by Tabla)
            FROM  app.tblCatCamposDinamicos s where s.Tabla in (Select item from App.Split(@filtroTablas,','))
        group by Tabla
		
	declare  @total  int
	declare @row int

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
			                    ,ISNULL(B.[Value], ''SIN DATO''),1,0
		                        From  (
			                        SELECT '  , @campos,' FROM ',@tabla,' WHERE  IDEmpleado= ',@IDEmpleado,				                    
		                        ') A
		                            Cross Apply OpenJSON(  (Select A.* For JSON Path, INCLUDE_NULL_VALUES, Without_Array_Wrapper ) ) B')        
        		
		insert into @tblCamposDinamicos ([KEY],[VALUE],TIPO,IDAviso)
        exec (@querySelect  )		 				
		set @row=@row+1;
	end	
    DECLARE  @json varchar(max)
    declare @totalCamposGenerales int 
    declare @totalCamposFinales int 
	
    select 
        @json=FileJson from Comunicacion.tblAvisos where IDAviso=@IDAviso                        
    select 
        @totalCamposGenerales= count(*) from @tblCamposDinamicos

    
    insert into @tblCamposDinamicos ([KEY],[VALUE],TIPO,IDAviso)
    select [Key],[Value],2,@IDAviso From (
            select  
                B.[key] AS [Key]
                ,B.[value] AS [Value]  
                ,JSON_VALUE(A.[value],'$.CLAVEEMPLEADO') AS ID
                FROM OPENJSON(@json,'$.results') a
                CROSS APPLY OPENJSON(A.[value]) B 
    )     as tabla    
    where ID=@ClaveEmpleado

    select 
        @totalCamposFinales= count(*) from @tblCamposDinamicos     

    if(@totalCamposGenerales=@totalCamposFinales)
    begin 
        insert into @tblCamposDinamicos ([KEY],[VALUE],TIPO,IDAviso)
        select  
                value , '' , 2,13 FROM OPENJSON(@json,'$.header') 
    end

    select * From @tblCamposDinamicos

END
GO
