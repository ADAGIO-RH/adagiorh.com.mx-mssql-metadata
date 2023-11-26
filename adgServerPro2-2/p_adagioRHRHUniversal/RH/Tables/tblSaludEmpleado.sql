USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblSaludEmpleado](
	[IDSaludEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[TipoSangre] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Estatura] [decimal](10, 2) NULL,
	[Peso] [decimal](10, 2) NULL,
	[IMC] [decimal](10, 2) NULL,
	[Alergias] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IMCC] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TratamientoAlergias] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[RequiereTarjetaSalud] [bit] NULL,
	[VencimientoTarjeta] [date] NULL,
 CONSTRAINT [Pk_RHTblSaludEmpleado_IDSaludEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDSaludEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHtblSaludEmpleado_IDEmpleado] ON [RH].[tblSaludEmpleado]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblSaludEmpleado] ADD  DEFAULT ((0)) FOR [RequiereTarjetaSalud]
GO
ALTER TABLE [RH].[tblSaludEmpleado]  WITH CHECK ADD  CONSTRAINT [FK_RHTblSaludEmpleado_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
GO
ALTER TABLE [RH].[tblSaludEmpleado] CHECK CONSTRAINT [FK_RHTblSaludEmpleado_IDEmpleado]
GO
