USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUpdatePeriodoInicioFin]  
(  
 @IDPeriodo int,  
 @Columna varchar(50),  
 @Value bit  
)  
AS  
BEGIN  
 Declare @query Varchar(max)  
  
 Set @query = 'UPDATE Nomina.tblCatPeriodos set @Column = @Value where IDPeriodo = @IDPeriodo'  
   
 set @query = REPLACE(REPLACE(REPLACE(@query,'@Column',@Columna),'@Value',cast(@Value as Varchar)),'@IDPeriodo',cast(@IDPeriodo as Varchar))  
  
 Execute(@query);  

 if(@Columna in('Finiquito') and @Value = 1)
 BEGIN
  UPDATE Nomina.tblCatPeriodos 
	set Especial = 0 
		,General = 0
		,Aguinaldo = 0
		,PTU = 0
	    ,DevolucionFondoAhorro = 0
	where IDPeriodo = @IDPeriodo 
 END
 ELSE IF(@Columna in('General')and @Value = 1)
 BEGIN
    UPDATE Nomina.tblCatPeriodos 
	set Especial = 0
	 ,Finiquito = 0
	 	,Aguinaldo = 0
		,PTU = 0
	    ,DevolucionFondoAhorro = 0
	 where IDPeriodo = @IDPeriodo 
 END
 ELSE IF(@Columna in('Especial')and @Value = 1)
 BEGIN
    UPDATE Nomina.tblCatPeriodos 
	set General = 0
	 ,Finiquito = 0
	 where IDPeriodo = @IDPeriodo 
 END
 ELSE IF(@Columna in('Aguinaldo')and @Value = 1)
 BEGIN
    UPDATE Nomina.tblCatPeriodos 
	set PTU = 0
	 ,DevolucionFondoAhorro = 0
	 where IDPeriodo = @IDPeriodo 
 END
 ELSE IF(@Columna in('PTU')and @Value = 1)
 BEGIN
    UPDATE Nomina.tblCatPeriodos 
	set Aguinaldo = 0
	 ,DevolucionFondoAhorro = 0
	 where IDPeriodo = @IDPeriodo 
 END
 ELSE IF(@Columna in('DevolucionFondoAhorro')and @Value = 1)
 BEGIN
    UPDATE Nomina.tblCatPeriodos 
	set Aguinaldo = 0
	 ,PTU = 0
	 where IDPeriodo = @IDPeriodo 
 END
END
GO
